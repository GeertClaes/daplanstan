class FetchTripCoverImageJob < ApplicationJob
  queue_as :default

  def perform(trip_id)
    trip = Trip.find_by(id: trip_id)
    return unless trip

    access_key = ENV["PEXELS_API_KEY"]
    return Rails.logger.info("[FetchTripCoverImageJob] No PEXELS_API_KEY set") unless access_key.present?

    # Strip 4-digit years from the title so we get better photo results
    clean_title = trip.title.gsub(/\b\d{4}\b/, "").squeeze(" ").strip
    query = URI.encode_www_form_component("#{clean_title} travel landscape")
    uri   = URI("https://api.pexels.com/v1/search?query=#{query}&per_page=1&orientation=landscape")

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = access_key
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.warn "[FetchTripCoverImageJob] Pexels returned #{response.code}"
      return
    end

    data      = JSON.parse(response.body)
    image_url = data.dig("photos", 0, "src", "large2x")
    trip.update_columns(cover_image_url: image_url) if image_url

    Rails.logger.info "[FetchTripCoverImageJob] Cover image set for trip #{trip_id}"
  rescue => e
    Rails.logger.warn "[FetchTripCoverImageJob] Failed: #{e.message}"
  end
end
