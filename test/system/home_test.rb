require "application_system_test_case"

class HomeTest < ApplicationSystemTestCase
  test "should show home as root" do
    visit root_url

    assert_title "Down Under Sports"
  end
end
