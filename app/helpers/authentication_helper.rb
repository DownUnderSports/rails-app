module AuthenticationHelper
  def is_logged_in?
    @authenticator&.logged_in?
  end
end
