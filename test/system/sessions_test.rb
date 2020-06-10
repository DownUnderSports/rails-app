require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  setup do
    @session = sessions(:one)
  end

  test "visiting the index" do
    visit session_url
    assert_selector "h1", text: "Sessions"
  end

  test "creating a Session" do
    visit new_session_url

    click_on "Create Session"

    assert_text "Session was successfully created"
    click_on "Back"
  end

  test "destroying a Session" do
    visit session_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Session was successfully destroyed"
  end
end
