module TestHelper
  module TemplateAssertions
    module Integration
      http_verbs = %w(get post patch put head delete)

      http_verbs.each do |method|
        define_method(method) do |*args, **opts, &block|
          reset_template_assertion
          block_given? ? super(*args, **opts, &block) : super(*args, **opts)
        end
      end
    end
  end
end
