# frozen_string_literal: true

if defined?(Redis) && defined?(Redis::Namespace)

  tmp_rds = Redis::Namespace.new("#{Rails.application.class.parent_name}::active_page", redis: Redis.new(url: ENV.fetch('REDIS_URL') { 'redis://localhost:6379/1' }))

  tmp_rds.get('test')

  Rails.application.class.parent.const_set('REDIS', tmp_rds)

  module Rails
    def self.redis
      Rails.application.class.parent.const_get('REDIS')
    end
  end
end
