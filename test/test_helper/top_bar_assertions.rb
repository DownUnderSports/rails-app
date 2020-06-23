require 'active_support/lazy_load_hooks'
require_relative './template_assertions/core'
require_relative './template_assertions/integration'

module TestHelper
  module TopBarAssertions
    # == Constants ============================================================
    ANIMATION_CLASSES = %w[
      mdc-drawer--animate
      mdc-drawer--opening
      mdc-drawer--closing
    ].freeze

    # == Extensions ===========================================================
    extend ActiveSupport::Concern

    # == Activation ===========================================================
    def self.install
      ActiveSupport.on_load(:action_dispatch_system_test_case) do
        include TestHelper::TopBarAssertions
      end
    end

    # == Instance Methods =====================================================
    def top_bar
      find("header#top-bar", visible: :all)
    end

    def assert_has_top_bar
      assert_selector "header#top-bar",
                      visible: :visible,
                      count: 1,
                      class: %w[ mdc-top-app-bar mdc-top-app-bar--fixed ]
    end
  end
end
