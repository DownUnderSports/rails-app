require 'active_support/concern'

module TestHelper
  module TemplateAssertions
    module Core
      extend ActiveSupport::Concern

      included do
        setup :setup_subscriptions
        teardown :teardown_subscriptions
      end

      RENDER_SUBTEMPLATE_KEYS = %i[ partial layout file ].freeze
      RENDER_TEMPLATE_INSTANCE_VARIABLES = %i[ templates partials layouts files ].freeze

      def setup_subscriptions
        RENDER_TEMPLATE_INSTANCE_VARIABLES.each do |instance_variable|
          instance_variable_set("@_#{instance_variable}", Hash.new(0))
        end

        @_subscribers = []

        @_subscribers << ActiveSupport::Notifications.subscribe("render_template.action_view") do |_name, _start, _finish, _id, payload|
          path = payload[:layout]
          if path
            @_layouts[path] += 1
            if path =~ /^layouts\/(.*)/
              @_layouts[$1] += 1
            end
          end
        end

        @_subscribers << ActiveSupport::Notifications.subscribe("!render_template.action_view") do |_name, _start, _finish, _id, payload|
          if virtual_path = payload[:virtual_path]
            if virtual_path =~ /^(.*\/)_([^\/]*)$/
              partial = "#{$1}#{$2}"
              @_partials[virtual_path] += 1
              @_partials[partial] += 1
            else
              @_templates[virtual_path] += 1
            end
          elsif path = payload[:identifier]
            @_files[path] += 1
            @_files[path.split("/").last] += 1
          end
        end
      end

      def teardown_subscriptions
        return unless defined?(@_subscribers)
        @_subscribers.each do |subscriber|
          ActiveSupport::Notifications.unsubscribe(subscriber)
        end
      end

      def process(*, **)
        reset_template_assertion
        super
      end

      def reset_template_assertion
        RENDER_TEMPLATE_INSTANCE_VARIABLES.each do |instance_variable|
          ivar_name = "@_#{instance_variable}"
          if instance_variable_defined?(ivar_name)
            instance_variable_get(ivar_name).clear
          end
        end
      end

      def assert_layout(layout)
        assert_template layout: "layouts/#{layout.delete_prefix("layouts/")}"
      end

      def assert_application_layout
        assert_layout "application"
        assert_template partial: "layouts/top_bar", count: 1
        assert_template partial: "layouts/app_drawer", count: 1
      end

      # Asserts that the request was rendered with the appropriate template file or partials.
      #
      #   # assert that the "new" view template was rendered
      #   assert_template "new"
      #
      #   # assert that the exact template "admin/posts/new" was rendered
      #   assert_template %r{\Aadmin/posts/new\Z}
      #
      #   # assert that the layout 'admin' was rendered
      #   assert_template layout: 'admin'
      #   assert_template layout: 'layouts/admin'
      #   assert_template layout: :admin
      #
      #   # assert that no layout was rendered
      #   assert_template layout: nil
      #   assert_template layout: false
      #
      #   # assert that the "_customer" partial was rendered twice
      #   assert_template partial: '_customer', count: 2
      #
      #   # assert that no partials were rendered
      #   assert_template partial: false
      #
      #   # assert that a file was rendered
      #   assert_template file: "README.rdoc"
      #
      #   # assert that no file was rendered
      #   assert_template file: nil
      #   assert_template file: false
      #
      # In a view test case, you can also assert that specific locals are passed
      # to partials:
      #
      #   # assert that the "_customer" partial was rendered with a specific object
      #   assert_template partial: '_customer', locals: { customer: @customer }
      def assert_template(expected = nil, message: nil, count: nil, match_end: false, **options)
        # Force body to be read in case the template is being streamed.
        response.body

        basic = case expected
                when NilClass
                  !options[:layout] \
                  && !options[:partial] \
                  && !options[:file]
                when Regexp, String, Symbol, FalseClass
                  true
                else
                  raise \
                    ArgumentError,
                    "assert_template only accepts a " \
                    "String, Symbol, Hash, Regexp, false or nil"
                end

        if basic
          expected = expected.to_s if Symbol === expected
          rendered = @_templates
          msg = message || (
            name.present? ?
              "expected <%s> rendered %s times, but rendered with <%s>" :
              "expected nothing rendered, but rendered <%[2]s>"
          )

          template_did_match \
            expected: expected,
            message: msg,
            rendered: @_templates,
            count: count,
            match_end: match_end
        else
          RENDER_SUBTEMPLATE_KEYS.each do |key|
            if options.key?(key)
              expected = options[key].presence
              ivar_name = "@_#{key}s"


              msg = message || (
                expected ?
                  "expected #{key} <%s> rendered %s times, but rendered with <%s>" :
                  "expected no #{key} rendered, but rendered <%[2]s>"
              )

              template_did_match \
                expected: expected,
                message: msg,
                rendered: instance_variable_get(ivar_name),
                count: count,
                match_end: match_end

              if key == :partial && (expected_locals = options[:locals])
                if expected_locals = defined?(@_rendered_views)
                  view = expected_partial.to_s.sub(/^_/, '').sub(/\/_(?=[^\/]+\z)/, '/')

                  msg = "expecting %s to be rendered with %s "\
                        "but was rendered with %s" \
                        % [
                            expected_partial,
                            expected_locals,
                            @_rendered_views.locals_for(view)
                          ]

                  assert(@_rendered_views.view_rendered?(view, expected_locals), msg)
                else
                  warn "the :locals option to #assert_template is only supported in a ActionView::TestCase"
                end
              end
            end
          end
        end
      end

      private
        def template_did_match(expected:, message:, rendered:, count: nil, match_end: false)
          expected = false if expected.is_a?(String) && expected.empty?

          matches_template =
            case expected
            when String
              rendered.any? do |given, given_count|
                if given_count == (count || given_count)
                  if match_end
                    expected = expected.split(File::SEPARATOR)
                    given = t.split(File::SEPARATOR).
                              last(expected.size)
                  end
                  given == expected
                else
                  false
                end
              end
            when Regexp
              rendered.any? { |t,num| t.match(expected) }
            when NilClass, FalseClass
              rendered.blank?
            else
              raise \
                ArgumentError,
                "assert_template only accepts a " \
                "String, Symbol, Regexp, nil or false for paths"
            end

          assert \
            matches_template,
            sprintf(
              message,
              expected.inspect,
              count || "at least 1",
              rendered.keys
            )
        end
    end
  end
end
