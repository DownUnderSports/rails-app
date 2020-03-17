Rails.application.config.session_store :cookie_store, expire_after: Rails.env.production? ? 24.hours : nil, secure: Rails.env.production?, httponly: true
