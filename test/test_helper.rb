ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/mock'

ActiveSupport.on_load(:active_support_test_case) do
  require_relative './test_helper/core'

  include TestHelper::Core
end
