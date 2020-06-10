require "application_system_test_case"

class HomeTest < ApplicationSystemTestCase
  test "should show home as root" do
    visit root_url

    assert_title "Home - Down Under Sports"
  end

  test "should show contact information" do
    visit root_url

    take_screenshot

    assert_selector ".mdc-card a[href=\"mailto:gbspropertiesmanagement@gmail.com\"]",
                    text: "gbspropertiesmanagement@gmail.com"
    assert_selector ".mdc-card a[href=\"tel:+14355541184\"]",
                    text: "435-554-1184"
  end

  test "should show hours" do
    visit root_url

    take_screenshot

    assert_selector ".mdc-list.mdc-list--two-line" do
      [
        [ "Monday - Thursday", "10 AM - 4 PM (MST)" ],
        [ "Friday", "10 AM - 1 PM (MST)" ]
      ].each do |label, time|
        assert_selector ".mdc-list-item__primary-text", text: label
        assert_selector ".mdc-list-item__secondary-text", text: time
      end
    end
  end
end
