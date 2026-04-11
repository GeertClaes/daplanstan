Geocoder.configure(
  lookup:      :nominatim,
  use_https:   true,
  units:       :km,
  timeout:     10,
  http_headers: { "User-Agent" => "Daplanstan/1.0 (#{ENV.fetch("POSTMARK_FROM_EMAIL", "noreply@daplanstan.com")})" }
)
