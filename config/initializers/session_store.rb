# Share the session cookie across daplanstan.com and whats.daplanstan.com
# so a user logged in on one subdomain is recognised on the other.
# In development (localhost) the domain option has no effect.
Rails.application.config.session_store :cookie_store,
  key: "_daplanstan_session",
  domain: Rails.env.production? ? ".daplanstan.com" : :all,
  same_site: :lax,
  secure: Rails.env.production?
