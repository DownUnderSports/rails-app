ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/mock'
require_relative './test_helper/core'

class ActiveSupport::TestCase
  include TestHelper::Core
end
