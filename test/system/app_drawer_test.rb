require "application_system_test_case"

class AppDrawerTest < ApplicationSystemTestCase
  test "should exist" do
    visit root_url

    assert_has_app_drawer :all
  end

  test "should start hidden" do
    visit root_url

    assert_has_app_drawer :hidden
  end


  test "should toggle visibility" do
    visit root_url

    assert_has_app_drawer :hidden

    toggle_app_drawer

    assert_has_app_drawer :visible

    toggle_app_drawer

    assert_has_app_drawer :hidden
  end

  test "should show contact information" do
    visit root_url

    item_css  = "a.mdc-list-item"
    email_css = item_css +
                "[href=\"mailto:mail@downundersports.com\"]"
    phone_css = item_css +
                "[href=\"tel:+14357534732\"]"

    set_app_drawer_visible

    app_drawer.assert_selector :xpath, app_drawer_subheader_xpath("Contact")

    path = app_drawer_list_xpath "Contact",
                      classes: %w[ mdc-list ],
                      text: "mail@downundersports.com",
                      tag: "div"

    list = app_drawer.find :xpath, path


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

    set_app_drawer_visible

    app_drawer.assert_selector :xpath, app_drawer_subheader_xpath("Hours")

    path = app_drawer_list_xpath "Hours",
                      classes: %w[ mdc-list mdc-list--two-line ],
                      text: "Tuesday - Thursday",
                      tag: "ul"
    list = app_drawer.find :xpath, path

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

end
