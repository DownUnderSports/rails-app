# frozen_string_literal: true

if defined?(Redis) && defined?(Redis::Namespace)

  begin
    tmp_rds = Redis::Namespace.new("#{Rails.application.class.module_parent_name}::active_page", redis: Redis.new(url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }))

    tmp_rds.get("test")
  rescue
    if !Rails.env.production?
      Rails.logger.warn { "WARNING!!! Redis Server not found" }
      tmp_rds = TinyFakeRedis.new
    else
      raise
    end
  end

  Rails.application.class.module_parent.const_set("REDIS", tmp_rds)

  module Rails
    def self.redis
      Rails.application.class.module_parent.const_get("REDIS")
    end
  end
end
