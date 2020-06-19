require 'test_helper'

class ApplicationLayoutTest < ActionView::TestCase
  test "application layout renders drawer and header" do
    render layout: "layouts/application", html: ""

    assert_template partial: "layouts/top_bar", count: 1
    assert_template partial: "layouts/app_drawer", count: 1
  end
end
