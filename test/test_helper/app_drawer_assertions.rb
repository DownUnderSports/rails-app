require 'active_support/lazy_load_hooks'
require_relative './template_assertions/core'
require_relative './template_assertions/integration'

module TestHelper
  module AppDrawerAssertions
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
        include TestHelper::AppDrawerAssertions
      end
    end

    # == Instance Methods =====================================================
    def app_drawer
      find("aside#app-drawer", visible: :all)
    end

    def assert_has_app_drawer(visible = :all)
      classes = %w[ mdc-drawer mdc-drawer--modal ]
      case visible
      when :hidden
        classes << "!mdc-drawer--open"
      when :visible
        classes << "mdc-drawer--open"
      end

      assert_selector "aside#app-drawer",
                      visible: visible,
                      count: 1,
                      class: classes
      assert_selector "#drawer-scrim",
                      visible: visible,
                      count: 1,
                      class: [ "mdc-drawer-scrim" ]
    end

    def with_open_app_drawer
      visible = app_drawer.visible?
      set_app_drawer_visible true
      begin
        yield
      ensure
        set_app_drawer_visible visible
      end
    end

    def set_app_drawer_visible(value = true)
      wait_for_animation do
        return app_drawer.visible? if app_drawer.visible? == !!value
        if value
          find("#drawer-toggle-button").click
        else
          find("#drawer-scrim").click
        end
      end
    end

    def toggle_app_drawer
      set_app_drawer_visible !app_drawer.visible?
    end

    def wait_for_animation
      loop_app_drawer_animation

      yield

      loop_app_drawer_animation
    end

    def loop_app_drawer_animation
      i = 25.0
      loop do
        break unless (i > 0) && (app_drawer_class_list & ANIMATION_CLASSES).any?

        sleep(1.0/[i -= 1.0, 1.0].max)
      end
    end

    def app_drawer_class_list
      app_drawer[:class].split(" ")
    rescue
      []
    end

    def app_drawer_subheader_xpath(text)
      ".//h6" \
        "[contains(@class, 'mdc-list-group__subheader')" \
        " and text()='#{text}']"
    end

    def app_drawer_list_xpath(header, *args, classes: [], tag: "*", text: nil)
      classes |= args.flatten

      unless classes.empty?
        classes.map! do |klass|
          "contains(@class, '#{klass}')"
        end
      end

      classes << "contains(.,'#{text}')" if text

      app_drawer_subheader_xpath(header) +
      "/following-sibling::#{tag}[#{classes.join(" and ")}][1]"
    end
  end
end
