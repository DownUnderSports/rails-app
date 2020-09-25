require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = person_fixtures(:session).user
  end

  teardown do
    # when controller is using cache it may be a good idea to reset it afterwards
    @user.sessions.destroy_all
    Rails.cache.clear
  end

  def user_agent
    @user_agent ||= "Agent.#{rand}"
  end

  def get(*args, **opts)
    super *args, headers: { "HTTP_USER_AGENT" => user_agent }, **opts
  end

  def post(*args, **opts)
    super *args, headers: { "HTTP_USER_AGENT" => user_agent }, **opts
  end

  def delete(*args, **opts)
    super *args, headers: { "HTTP_USER_AGENT" => user_agent }, **opts
  end

  def login(**params)
    post session_url, params: { email: @user.email, **params }
  end

  def assert_renders_new(errors: nil)
    assert_select "form#new_session_form" do |forms|
      assert_equal 1, forms.size
      form = forms.first
      if errors
        assert_select form, "#main_errors" do |error_banners|
          assert_equal 1, error_banners.size
          banner = error_banners.first
          case errors
          when String
            assert_select banner, "p.error-message", errors
          when Array, Set
            assert_select banner, "p.error-message", errors.size
            errors.each do |error|
              assert_select banner, "p.error-message", error
            end
          else
            raise "Invalid Errors to Match"
          end
        end
      end
    end
  end

  def expected_session
    @user.sessions.find_by(ip_address: "127.0.0.1", user_agent: @user_agent)
  end

  def assert_session_exists
    assert expected_session.present?
    assert cookies["session_id"].present?
  end

  def refute_session_exists
    refute expected_session
    refute cookies["session_id"].present?
  end

  test "should get new" do
    get new_session_url
    assert_response :success
    assert_renders_new
  end

  test "should create session if given correct credentials" do
    assert_difference("User::Session.count", 1) do
      login password: "session.test"
    end

    assert_response :found

    assert_session_exists

    assert_redirected_to root_url
  end

  test "should render new if given incorrect credentials" do
    assert_no_difference("User::Session.count") do
      login password: "password"
    end

    assert_response :unauthorized

    refute_session_exists

    assert_equal session_path, path
    assert_renders_new errors: "Email/Password combination not found"
  end

  test "should redirect to :after_login param when authenticated" do
    login password: "session.test", after_login: "/test-path"

    assert_session_exists

    assert_redirected_to "/test-path"

    get new_session_url(after_login: "http://example.com/test-url")

    assert_redirected_to "http://example.com/test-url"
  end

  test "should destroy session" do
    login password: "session.test"

    assert_session_exists

    assert_difference("User::Session.count", -1) do
      delete session_url
    end

    refute_session_exists

    assert_redirected_to root_url
  end

  test "get new should redirect already authenticated users" do
    login password: "session.test"

    assert_session_exists

    get new_session_url

    assert_redirected_to root_url
  end

  test "should destroy an existing session if a bad login is posted" do
    login password: "session.test"

    assert_session_exists

    assert_difference("User::Session.count", -1) do
      login password: "password"
    end

    refute_session_exists

    assert_renders_new errors: "Email/Password combination not found"
  end
end
