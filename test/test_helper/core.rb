require "active_support/concern"

require_relative "./app_drawer_assertions"
require_relative "./database_assertions"
require_relative "./method_assertions"
require_relative "./template_assertions"
require_relative "./tmp_classes"
require_relative "./top_bar_assertions"
require_relative "./webpacker_stubs"

module TestHelper
  module Core
    # == Constants ============================================================

    # == Extensions ===========================================================
    extend ActiveSupport::Concern

    # == Activation ===========================================================
    included do
      # Run tests in parallel with specified workers
      unless CoerceBoolean.from(ENV['SYNC_TEST'])
        parallelize(workers: :number_of_processors)
      end

      # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
      fixtures :all

      AppDrawerAssertions.install
      TemplateAssertions.install
      TopBarAssertions.install
      WebpackerStubs.install

      include DatabaseAssertions
      include MethodAssertions

      setup do
        Rails.logger&.silence { Rails.application.load_seed } \
        || Rails.application.load_seed
      end
    end

    # == Instance Methods =====================================================
    def assert_hash_equal(expected, given)
      assert_equal expected.keys.sort, given.keys.sort
      (expected.keys | given.keys).map do |k|
        assert_equal expected[k], given[k]
      end
    end

    def valid_attributes
      raise "not implemented"
    end

    def attributes_without(*keys)
      valid_attributes.except(*keys)
    end
  end
end
