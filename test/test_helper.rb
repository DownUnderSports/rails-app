ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require_relative './tmp_classes'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  unless Boolean.parse(ENV['SYNC_TEST'])
    parallelize(workers: :number_of_processors)
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def assert_alias_of(object, original_name, aliased_name)
    assert_equal \
      object.method(original_name).original_name,
      object.method(aliased_name).original_name
  end

  def assert_hash_equal(expected, given)
    assert_equal expected.keys.sort, given.keys.sort
    (expected.keys | given.keys).map do |k|
      assert_equal expected[k], given[k]
    end
  end
end
