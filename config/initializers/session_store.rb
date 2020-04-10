sesh_key = (ENV["SESSION_KEY"] || ENV["CURRENT_APP_NAME"] || "_dus_rails_app").underscore
sesh_key = "_#{sesh_key}" unless sesh_key[0] == "_"
cookie_domain = Rails.env.production? ? '.downundersports.com' : '.lvh.me'

Rails.
  application.
  config.
  session_store(
    :cookie_store,
    key: sesh_key,
    domain: cookie_domain,
    expire_after: Rails.env.production? ? 24.hours : nil,
    secure: Rails.env.production?
  )
