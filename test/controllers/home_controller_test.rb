require 'test_helper'

class HomesControllerTest < ActionDispatch::IntegrationTest
  test "root should get show" do
    assert_routing root_path, controller: "home", action: "show"
    get root_url
    assert_response :success
  end
end
