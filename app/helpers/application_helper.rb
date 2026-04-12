module ApplicationHelper
  include Pagy::NumericHelpers

  # Inline an SVG from app/assets/images, converting fill="black" to currentColor
  # so Tailwind text-* classes control the colour.
  def inline_svg(filename, css_class: "h-5 w-5")
    path = Rails.root.join("app/assets/images/#{filename}")
    return "".html_safe unless File.exist?(path)

    svg = File.read(path)
    svg = svg.gsub('fill="black"', 'fill="currentColor"')
    # Remove hardcoded dimensions — let CSS control size
    svg = svg.sub(/\s*width="\d+"/, "").sub(/\s*height="\d+"/, "")
    # Inject class onto the <svg> element
    svg = svg.sub("<svg ", "<svg class=\"#{css_class}\" ")
    svg.html_safe
  end

  # Extract a short display city from a full address string.
  # "Via Insanguine 9, 70043 Monopoli BA, Italy" -> "Monopoli"
  def city_from_address(address)
    return nil unless address.present?
    parts = address.split(",").map(&:strip).reject(&:empty?)
    return parts.first if parts.length < 2
    segment = parts[-2]
    # Strip leading postcode digits and trailing 2-3 letter state codes
    segment.gsub(/\A\d+\s*/, "").gsub(/\s+[A-Z]{2,3}\z/, "").strip.presence
  end

  # Returns a human-friendly relative date string for expense display.
  # "Today", "Yesterday", weekday name (within last 6 days), or "d Mon YYYY".
  def relative_expense_date(date)
    days_ago = (Date.current - date.to_date).to_i
    case days_ago
    when 0 then "Today"
    when 1 then "Yesterday"
    when 2..6 then date.strftime("%A")
    else date.strftime("%-d %b %Y")
    end
  end

  # Returns a displayable URL for a trip's cover image.
  # Prefers an uploaded Active Storage image over the Pexels URL.
  def trip_cover_src(trip)
    return url_for(trip.cover_image) if trip.cover_image.attached?
    trip.cover_image_url.presence
  end
end
