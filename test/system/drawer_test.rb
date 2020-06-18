require "application_system_test_case"

class DrawerTest < ApplicationSystemTestCase
  ANIMATION_CLASSES = %w[
    mdc-drawer--animate
    mdc-drawer--opening
    mdc-drawer--closing
  ].freeze

  test "should exist" do
    visit root_url

    assert_has_drawer :all
  end

  test "should start hidden" do
    visit root_url

    assert_has_drawer :hidden
  end


  test "should toggle visibility" do
    visit root_url

    assert_has_drawer :hidden

    toggle_drawer

    assert_has_drawer :visible

    toggle_drawer

    assert_has_drawer :hidden
  end

  test "should show contact information" do
    visit root_url

    item_css  = "a.mdc-list-item"
    email_css = item_css +
                "[href=\"mailto:mail@downundersports.com\"]"
    phone_css = item_css +
                "[href=\"tel:+14357534732\"]"

    set_drawer_visible

    drawer.assert_selector :xpath, subheader_xpath("Contact")

    path = list_xpath "Contact",
                      classes: %w[ mdc-list ],
                      text: "mail@downundersports.com",
                      tag: "div"

    list = drawer.find :xpath, path


    list.assert_selector email_css, count: 1
    list.assert_selector email_css + " .mdc-list-item__text",
                           count: 1,
                           exact_text: "mail@downundersports.com"
    list.assert_selector email_css + " .mdc-list-item__graphic",
                           count: 1,
                           exact_text: "email"

    list.assert_selector phone_css, count: 1
    list.assert_selector phone_css + " .mdc-list-item__text",
                           count: 1,
                           exact_text: "435-753-4732"
    list.assert_selector phone_css + " .mdc-list-item__graphic",
                           count: 1,
                           exact_text: "phone"
    list.assert_selector phone_css + " .mdc-list-item__meta",
                           count: 1,
                           exact_text: "sms"
  end

  test "should show hours" do
    visit root_url

    set_drawer_visible

    drawer.assert_selector :xpath, subheader_xpath("Hours")

    path = list_xpath "Hours",
                      classes: %w[ mdc-list mdc-list--two-line ],
                      text: "Tuesday - Thursday",
                      tag: "ul"
    list = drawer.find :xpath, path

    primary_css = ".mdc-list-item " \
                  "> .mdc-list-item__text " \
                  "> .mdc-list-item__primary-text"

    secondary_xpath = ".//following-sibling::span" \
                      "[@class='mdc-list-item__secondary-text']" \
                      "[1]"

    [
      [ "Tuesday - Thursday", "2 PM - 4 PM (MDT)" ],
      [ "Friday", "Closed" ]
    ].each do |label, time|
      list.assert_selector primary_css, text: label

      primary = list.find(primary_css, text: label)

      primary.assert_selector :xpath, secondary_xpath, text: time
    end
  end

  private
    def drawer
      find("aside#app-drawer", visible: :all)
    end

    def assert_has_drawer(visible = :all)
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

    def with_open_drawer
      visible = drawer.visible?
      set_drawer_visible true
      begin
        yield
      ensure
        set_drawer_visible visible
      end
    end

    def set_drawer_visible(value = true)
      wait_for_animation do
        return drawer.visible? if drawer.visible? == !!value
        if value
          find("#drawer-toggle-button").click
        else
          find("#drawer-scrim").click
        end
      end
    end

    def toggle_drawer
      set_drawer_visible !drawer.visible?
    end

    def wait_for_animation
      loop_animation

      yield

      loop_animation
    end

    def loop_animation
      i = 10.0
      loop do
        break unless (i > 0) && (drawer_class_list & ANIMATION_CLASSES).any?
        i -= 1.0

        sleep(1.0/i)
      end
    end

    def drawer_class_list
      drawer[:class].split(" ")
    rescue
      []
    end

    def subheader_xpath(text)
      ".//h6" \
        "[contains(@class, 'mdc-list-group__subheader')" \
        " and text()='#{text}']"
    end

    def list_xpath(header, *args, classes: [], tag: "*", text: nil)
      classes |= args.flatten

      unless classes.empty?
        classes.map! do |klass|
          "contains(@class, '#{klass}')"
        end
      end

      classes << "contains(.,'#{text}')" if text

      subheader_xpath(header) +
      "/following-sibling::#{tag}[#{classes.join(" and ")}][1]"
    end
end
