require 'test_helper'

class AuthenticationHelperTest < ActionView::TestCase
  include AuthenticationHelper

  def authenticator_struct
    Struct.new(:logged_in) do
      def logged_in?
        logged_in
      end
    end
  end

  test "#is_logged_in? returns false if @authenticator is nil" do
    @authenticator = nil

    refute is_logged_in?
  end

  test "#is_logged_in? calls @authenticator#logged_in?" do
    @authenticator = authenticator_struct.new false

    refute is_logged_in?

    @authenticator = authenticator_struct.new true

    assert is_logged_in?
  end

  test "#is_logged_in? raises NoMethodError if @authenticator is invalid" do
    @authenticator = false

    err = assert_raises(NoMethodError) do
      is_logged_in?
    end

    assert_match "undefined method `logged_in?'", err.message
  end
end
