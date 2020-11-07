# encoding: utf-8
# frozen_string_literal: true

class UsersController < ApplicationController
  # == Modules ============================================================

  # == Class Methods ======================================================

  # == Pre/Post Flight Checks =============================================

  # == Actions ============================================================
  def new
    @user = User.new
  end

  def create
    purge_previous_avatar
    @user = User.new(category: :athlete, **whitelisted_user_params)
    if @user.save
      login(@user)
      redirect_to(root_url)
    else
      @errors = @user.errors.full_messages
      render :new, status: 401, message: @errors.first
    end
  end

  # == Cleanup ============================================================

  # == Utilities ==========================================================
  private
    def whitelisted_user_params
      params.require(:user).
             permit(
               # :first_names,
               :middle_names,
               :last_names,
               :email,
               :password,
               :password_confirmation,
               :avatar
             )
    end

    def purge_previous_avatar
      if params[:user][:existing_avatar] \
            && params[:user][:avatar].present? \
            && (params[:user][:avatar] != params[:user][:existing_avatar])

        ActiveStorage::Blob.find_signed(params[:user][:existing_avatar])&.purge_later

      end
    rescue
      nil
    end
end
