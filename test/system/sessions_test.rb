require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  setup do
    @user = person_fixtures(:athlete)
  end

  def assert_logged_in
    find "span.mdc-list-item__text", text: "Log In", visible: :all
    assert_selector "span.mdc-list-item__text", text: "Logout", visible: :all
  end

  def assert_logged_out
    find "span.mdc-list-item__text", text: "Log In", visible: :all
    assert_selector "span.mdc-list-item__text", text: "Log In", visible: :all
  end

  def open_login_form
    visit root_url

    with_open_app_drawer do
      click_on "Log In"
    end

    assert_title "Log In"
  end

  def log_in(email: @user.email, password: "password")
    fill_in "Email", with: email
    fill_in "Password", with: password

    click_on "Submit"
  end

  def log_out
    with_open_app_drawer do
      click_on "Logout"
    end
  end

  test "Logging in and back out" do
    visit root_url

    assert_logged_out

    open_login_form
    log_in

    assert_logged_in

    log_out

    assert_logged_out
  end

  test "Bad credentials" do
    visit root_url

    assert_logged_out

    open_login_form
    log_in password: "wrong password"
    find("#main_errors")


    assert_logged_out
    assert_selector "#main_errors .error-message", text: "Email/Password combination not found"

    log_in

    assert_logged_in
  end
end
