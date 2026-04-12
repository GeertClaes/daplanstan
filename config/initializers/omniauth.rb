Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    ENV.fetch("GOOGLE_CLIENT_ID", nil),
    ENV.fetch("GOOGLE_CLIENT_SECRET", nil)

  provider :apple,
    ENV.fetch("APPLE_CLIENT_ID", nil),
    {
      team_id: ENV.fetch("APPLE_TEAM_ID", nil),
      key_id:  ENV.fetch("APPLE_KEY_ID", nil),
      pem:     ENV.fetch("APPLE_PRIVATE_KEY", "").gsub("\\n", "\n")
    }
end

OmniAuth.config.allowed_request_methods = [ :post ]
OmniAuth.config.silence_get_warning = true
