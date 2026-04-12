class InboxItem < ApplicationRecord
  belongs_to :trip
  belongs_to :reviewed_by, class_name: "User", optional: true

  broadcasts_refreshes_to :trip

  has_many :trip_items, dependent: :nullify
  has_many :expenses, dependent: :nullify

  has_many_attached :email_attachments

  enum :sender_status, { pending_approval: "pending_approval", approved: "approved", rejected: "rejected" }
  enum :parse_status,  { unparsed: "unparsed", parsed: "parsed", failed: "failed" }
  enum :review_status, { pending_review: "pending_review", confirmed: "confirmed", discarded: "discarded" }

  validates :from_email, presence: true
  validates :received_at, presence: true

  def parsed_data
    JSON.parse(parsed_data_json) if parsed_data_json.present?
  end

  def parsed_data=(hash)
    self.parsed_data_json = hash.to_json
  end

  # Creates trip_items and expenses from parsed AI data.
  # Called when the user clicks "Add to trip" on the email detail page.
  # Bookings/legs/accommodations → status: confirmed (they are confirmed reservations).
  # Shortlist suggestions → status: idea.
  # Expenses are created unsettled (confirmed_at nil) for the user to mark paid later.
  def confirm_and_create_items!(added_by)
    data = parsed_data
    return unless data.is_a?(Hash)

    # paid_by: prefer the traveler whose email matches the forwarded email sender,
    # fall back to the traveler of the user who clicked "Add to trip"
    paid_by_traveler = trip.trip_members.joins(:traveler)
                           .find_by(travelers: { email: from_email })&.traveler
    paid_by_traveler ||= trip.trip_members.joins(:traveler)
                             .find_by(travelers: { user_id: added_by.id })&.traveler

    leg_mode_to_kind = { "plane" => "flight", "train" => "train",
                         "ferry" => "ferry",  "bus"   => "car",  "car" => "car" }

    # Travel legs
    # For geocoding transport items the Geocodable concern needs an address.
    # Use the arrival location (destination) for outbound legs.
    # For a round trip (2 legs where leg[0] arrives at leg[1]'s departure), leg[1]
    # is the return — use its departure so both legs pin to the same destination.
    legs_data    = Array(data["travel_legs"])
    round_trip   = legs_data.size == 2 &&
      legs_data[0]["arrival_location"].to_s.split(/[\s,]+/).first.to_s.casecmp?(
        legs_data[1]["departure_location"].to_s.split(/[\s,]+/).first.to_s
      )

    flight_items = []
    legs_data.each_with_index do |leg, i|
      kind          = leg_mode_to_kind[leg["mode"]] || "other"
      name          = [ leg["carrier"].presence,
                        "#{leg["departure_location"]} \u2192 #{leg["arrival_location"]}" ].compact.join(" ")
      geocode_addr  = (round_trip && i > 0) ? leg["departure_location"] : leg["arrival_location"]

      item = trip.trip_items.create!(
        inbox_item:       self,
        added_by:         added_by,
        kind:             kind,
        name:             name,
        status:           :confirmed,
        starts_at:        leg["departure_datetime"].presence,
        ends_at:          leg["arrival_datetime"].presence,
        address:          geocode_addr.presence,
        amount:           leg["total_price"],
        currency:         leg["currency"],
        confirmation_ref: leg["booking_reference"]
      )
      flight_items << { item: item, data: leg }
    rescue => e
      Rails.logger.error "[InboxItem#confirm] travel leg failed: #{e.message}"
    end

    # One consolidated expense for all legs (avoids double-counting return trips)
    if paid_by_traveler
      priced_leg = flight_items.find { |f| f[:data]["total_price"].present? }
      if priced_leg
        origins = legs_data.map { |l| l["departure_location"] }.uniq
        carrier = priced_leg[:data]["carrier"].presence
        desc    = origins.length > 1 ? "#{origins.first} \u21c4 #{origins.last}" : origins.first.to_s
        desc   += " (#{carrier})" if carrier
        build_expense(priced_leg[:item], added_by, paid_by_traveler,
                      priced_leg[:data]["total_price"], priced_leg[:data]["currency"],
                      desc, :flight, priced_leg[:data]["departure_datetime"])
      end
    end

    # Accommodations
    Array(data["accommodations"]).each do |acc|
      item = trip.trip_items.create!(
        inbox_item:       self,
        added_by:         added_by,
        kind:             :stay,
        name:             acc["name"],
        status:           :confirmed,
        starts_at:        acc["check_in"].presence,
        ends_at:          acc["check_out"].presence,
        address:          acc["address"],
        amount:           acc["total_price"],
        currency:         acc["currency"],
        confirmation_ref: acc["confirmation_number"],
        notes:            acc["notes"]
      )
      if paid_by_traveler && acc["total_price"].present?
        build_expense(item, added_by, paid_by_traveler,
                      acc["total_price"], acc["currency"], acc["name"],
                      :stay, acc["check_in"])
      end
    rescue => e
      Rails.logger.error "[InboxItem#confirm] accommodation failed: #{e.message}"
    end

    # Bookings (tours, car hire, restaurants, etc.)
    booking_kind = ->(type) {
      t = type.to_s.downcase
      return "eat" if t =~ /restaurant|dining|food|eat/
      return "car" if t =~ /car|hire|rental/
      "do"
    }

    Array(data["bookings"]).each do |booking|
      kind = booking_kind.call(booking["booking_type"])
      item = trip.trip_items.create!(
        inbox_item:       self,
        added_by:         added_by,
        kind:             kind,
        name:             booking["provider"],
        status:           :confirmed,
        starts_at:        booking["datetime"].presence,
        ends_at:          booking["end_datetime"].presence,
        address:          booking["location"],
        amount:           booking["total_price"],
        currency:         booking["currency"],
        confirmation_ref: booking["confirmation_reference"],
        notes:            booking["notes"]
      )
      if paid_by_traveler && booking["total_price"].present?
        build_expense(item, added_by, paid_by_traveler,
                      booking["total_price"], booking["currency"], booking["provider"],
                      kind.to_sym, booking["datetime"])
      end
    rescue => e
      Rails.logger.error "[InboxItem#confirm] booking failed: #{e.message}"
    end

    # Shortlist suggestions — ideas only, no expense
    shortlist_kind = { "eat" => "eat", "see" => "do", "do" => "do",
                       "scout" => "do", "stay" => "stay" }

    Array(data["shortlist_items"]).each do |si|
      trip.trip_items.create!(
        inbox_item: self,
        added_by:   added_by,
        kind:       shortlist_kind[si["category"]] || "other",
        name:       si["name"],
        status:     :idea,
        address:    si["address"],
        notes:      si["notes"]
      )
    rescue => e
      Rails.logger.error "[InboxItem#confirm] shortlist item failed: #{e.message}"
    end
  end

  private

  def build_expense(trip_item, added_by, paid_by, amount, currency, description, category, date)
    trip.expenses.create!(
      trip_item:    trip_item,
      inbox_item:   self,
      added_by:     added_by,
      paid_by:      paid_by,
      amount:       amount,
      currency:     currency.presence || "EUR",
      description:  description,
      category:     category,
      expense_date: date.present? ? Date.parse(date.to_s) : Date.today,
      source:       :booking
    )
  rescue => e
    Rails.logger.error "[InboxItem#confirm] expense failed: #{e.message}"
  end
end
