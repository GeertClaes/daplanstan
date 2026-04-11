class TripItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip
  before_action :set_item, only: [ :show, :edit, :update, :destroy, :confirm, :to_expense ]

  def show
    sorted_ids = @trip.trip_items
                      .order(Arel.sql("starts_at IS NULL, starts_at ASC, created_at ASC"))
                      .pluck(:id)
    idx              = sorted_ids.index(@item.id) || 0
    @item_index      = idx + 1
    @item_count      = sorted_ids.size
    @prev_item_id    = sorted_ids[idx - 1] if idx > 0
    @next_item_id    = sorted_ids[idx + 1] if idx < sorted_ids.size - 1

    # For items from the same email (e.g. return flight leg), fall back to
    # the booking ref and expense shared across sibling trip_items.
    if @item.inbox_item_id.present?
      siblings         = @trip.trip_items.where(inbox_item_id: @item.inbox_item_id)
      @display_ref     = @item.confirmation_ref.presence ||
                         siblings.where.not(confirmation_ref: [ nil, "" ]).pick(:confirmation_ref)
      @display_expense = @item.expense ||
                         Expense.joins(:trip_item)
                                .find_by(trip_items: { inbox_item_id: @item.inbox_item_id })
    else
      @display_ref     = @item.confirmation_ref.presence
      @display_expense = @item.expense
    end
  end

  def import
    if request.post? && params[:confirm] == "1"
      result = bulk_create_items(JSON.parse(params[:items_json]))
      msg    = "#{result[:created]} idea(s) imported."
      msg   += " #{result[:skipped]} skipped (missing name)." if result[:skipped] > 0
      redirect_to trip_path(@trip, tab: "itinerary"), notice: msg
    elsif request.post?
      raw = params[:items_json].presence || params[:json_file]&.read
      if raw.blank?
        @parse_error = "Please paste JSON or upload a .json file."
        return render :import
      end
      begin
        parsed = JSON.parse(raw)
        raise ArgumentError, "Expected a JSON array" unless parsed.is_a?(Array)
        @preview_items = parsed
        @raw_json      = raw
        @skipped_count = parsed.count { |i| i["name"].blank? }
      rescue JSON::ParserError, ArgumentError => e
        @parse_error = e.message.truncate(120)
        @raw_json    = raw
      end
      render :import
    end
    # GET — just render the form
  end

  def new
    @item = TripItem.new(status: "idea", kind: "do")
  end

  def create
    @item = @trip.trip_items.new(item_params)
    @item.added_by = current_user

    if @item.save
      redirect_to trip_path(@trip, tab: "itinerary"), notice: "Item added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @item.update(item_params)
      redirect_to trip_trip_item_path(@trip, @item), notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy!
    redirect_to trip_path(@trip, tab: "itinerary"), notice: "Item removed."
  end

  def confirm
    new_status = @item.confirmed? ? :idea : :confirmed
    @item.update!(status: new_status)
    redirect_back fallback_location: trip_trip_item_path(@trip, @item)
  end

  # Redirect to the expense new form, pre-filling from this item.
  # Guards against creating a second expense if one already exists.
  def to_expense
    if @item.expense
      return redirect_to trip_expense_path(@trip, @item.expense),
                         alert: "This item already has an expense."
    end

    prefill = {
      description: @item.name,
      category:    @item.expense_category,
      expense_date: (@item.starts_at&.to_date || Date.today).iso8601,
      currency:    @item.currency.presence || "EUR",
      trip_item_id: @item.id
    }
    prefill[:amount] = "%.2f" % @item.amount if @item.amount.present?

    redirect_to new_trip_expense_path(@trip, expense: prefill)
  end

  private

  def set_trip
    @trip = current_user.trips.find(params[:trip_id])
  end

  def set_item
    @item = @trip.trip_items.find(params[:id])
  end

  VALID_IMPORT_KINDS = TripItem.kinds.keys.to_set

  def bulk_create_items(items)
    created = 0
    skipped = 0
    items.each do |data|
      next skipped += 1 if data["name"].blank?
      @trip.trip_items.create!(
        name:      data["name"],
        kind:      VALID_IMPORT_KINDS.include?(data["kind"].to_s) ? data["kind"].to_s : "other",
        status:    "idea",
        address:   data["address"].presence,
        notes:     data["notes"].presence,
        starts_at: parse_import_time(data["starts_at"]),
        ends_at:   parse_import_time(data["ends_at"]),
        amount:    data["amount"].presence,
        currency:  data["currency"].presence,
        added_by:  current_user
      )
      created += 1
    rescue => e
      Rails.logger.error "[TripItems#import] skipped item: #{e.message}"
      skipped += 1
    end
    { created: created, skipped: skipped }
  end

  def parse_import_time(val)
    Time.zone.parse(val.to_s) if val.present?
  rescue ArgumentError, TypeError
    nil
  end

  def item_params
    params.require(:trip_item).permit(
      :kind, :name, :status, :notes,
      :starts_at, :ends_at,
      :address, :amount, :currency, :confirmation_ref
    )
  end
end
