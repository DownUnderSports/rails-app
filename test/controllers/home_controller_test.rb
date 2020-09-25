require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "root should get show" do
    assert_routing root_path, controller: "home", action: "show"
    get root_url
    assert_template "home/show"
    assert_response :success
  end

  test "root should display \"our story\"" do
    get root_url

    assert_template partial: "home/our_story", count: 1

    assert_select "div.our-story" do |wrappers|
      assert_equal 1, wrappers.size
      titles = [
        "Who Are We?",
        "Our Story",
        "Our Mission Statement",
        "Our Vision"
      ]
      assert_select wrappers.first, ".mdc-card" do |cards|
        assert_equal titles.size, cards.size
        cards.each do |card|
          assert_select card, ".mdc-card__header.mdc-card--filled h2.mdc-typography--headline6", { count: 1, message: titles.pop }
        end
      end
    end
  end
end
