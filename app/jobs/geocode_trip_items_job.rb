class GeocodeTripItemsJob < ApplicationJob
  queue_as :default

  def perform(trip_item_ids, trip_id)
    trip = Trip.find_by(id: trip_id)
    return unless trip

    trip_item_ids.each do |id|
      item = TripItem.find_by(id: id)
      next unless item

      item.geocode_from_address
      Rails.logger.info "[GeocodeTripItemsJob] Geocoded item #{id}: #{item.latitude}, #{item.longitude}"
      sleep 1.1  # Nominatim rate limit: max 1 request/second
    rescue => e
      Rails.logger.warn "[GeocodeTripItemsJob] Failed for item #{id}: #{e.message}"
      sleep 1.1
    end

    # Broadcast a page refresh so map pins appear without the user doing anything
    Turbo::StreamsChannel.broadcast_refresh_to(trip)
  end
end
