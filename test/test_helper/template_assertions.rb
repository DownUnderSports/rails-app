require 'active_support/lazy_load_hooks'
require_relative './template_assertions/core'
require_relative './template_assertions/integration'

module TestHelper
  module TemplateAssertions
    def self.install
      ActiveSupport.on_load(:action_controller_test_case) do
        include TestHelper::TemplateAssertions::Core
      end

      ActiveSupport.on_load(:action_dispatch_integration_test) do
        include TestHelper::TemplateAssertions::Core
        include TestHelper::TemplateAssertions::Integration
      end

      ActiveSupport.on_load(:action_view_test_case) do
        include TestHelper::TemplateAssertions::Core
      end
    end
  end
end
