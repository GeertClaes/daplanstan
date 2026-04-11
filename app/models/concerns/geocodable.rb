module Geocodable
  extend ActiveSupport::Concern

  included do
    after_save :geocode_from_address,
      if: -> { (saved_change_to_address? || saved_change_to_name?) && !geocoded? }
  end

  def geocoded?
    latitude.present? && longitude.present?
  end

  def geocode_from_address
    result = geocode_with_bias || geocode_fallback
    if result
      update_columns(latitude: result.latitude, longitude: result.longitude)
      Rails.logger.info "[#{self.class.name}] Geocoded '#{name}': #{result.latitude},#{result.longitude}"
    else
      Rails.logger.warn "[#{self.class.name}] Could not geocode '#{name}'"
    end
  rescue => e
    Rails.logger.warn "[#{self.class.name}] Geocoding failed for '#{name}': #{e.message}"
  end

  private

  def geocode_with_bias
    return nil unless address.present?

    parts     = address.split(",").map(&:strip)
    city_hint = parts.last(2).join(", ")
    ref       = Geocoder.search(city_hint).first
    return Geocoder.search(address).first unless ref

    result = Geocoder.search(address, params: { lat: ref.latitude, lon: ref.longitude }).first
    return nil unless result

    dist = Geocoder::Calculations.distance_between(
      [ ref.latitude, ref.longitude ],
      [ result.latitude, result.longitude ],
      units: :km
    )
    dist < 50 ? result : nil
  end

  def geocode_fallback
    queries = []
    if address.present?
      parts = address.split(",").map(&:strip)
      queries << parts.last(2).join(", ") if parts.size > 2
      queries << parts.last(3).join(", ") if parts.size > 3
    end
    queries << "#{name}, #{trip.title}"
    queries << name
    queries.uniq.each do |q|
      result = Geocoder.search(q).first
      return result if result
    end
    nil
  end
end
