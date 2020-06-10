class SessionsController < ApplicationController
  # == Modules ============================================================

  # == Class Methods ======================================================

  # == Pre/Post Flight Checks =============================================
  before_action :redirect_value, only: [ :new, :create ]
  before_action :redirect_authenticated, only: [ :new ]

  # == Actions ============================================================
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate_password(params[:password])
      login(user)

      params[:after_login].present? ?
        redirect_to(params[:after_login]) :
        redirect_to(root_url)
    else
      logout current_session
      @errors = [ "Email/Password combination not found" ]
      render :new, status: 401, message: "Unauthorized: #{@errors.first}"
    end
  end

  def destroy
    logout current_session
    redirect_to root_url
  end

  # == Cleanup ============================================================

  # == Utilities ==========================================================
  private
    def check_status
      redirect_value
      redirect_authenticated
    end

    def redirect_authenticated
      return redirect_to redirect_value if logged_in?
    end

    def redirect_value
      @redirect_value ||= get_redirect_value
    end

    def get_redirect_value
      params[:after_login].presence || root_url
    end
end
