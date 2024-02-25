# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  layout 'admin'
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  before_action :authorize_global_admin
  before_action :configure_sign_up_params, only: [:new, :create]
  before_action :configure_account_update_params, only: [:new, :create]
  skip_before_action :require_no_authentication

  # GET /resource/sign_up
  def new
    @pages = Page.all.map { |page| [page.tag, page.tag] }.append(["All Pages", "global"], ["Archivist must be true to select page access", nil, {id: "nil-value"}]).reverse()
    @submit_text = "Register New User"
    @user = User.new
  end
  
  # POST /resource
  def create
    @pages = Page.all.map { |page| [page.tag, page.tag] }.append(["All Pages", "global"], ["Archivist must be true to select page access", nil, {id: "nil-value"}]).reverse() 
    @user = User.new(sign_up_params)

    if @user.save
      redirect_to users_path
    else
      render :new
    end
  end

  # GET /resource/edit
  def edit
    @user = User.find(params[:format])
    @pages = Page.all.map { |page| [page.tag, page.tag] }.append(["All Pages", "global"], ["Archivist must be true to select page access", nil, {id: "nil-value"}]).reverse()
    super
  end

  # PUT /resource
  def update
    @user = User.find(params[:user][:id])
    @pages = Page.all.map { |page| [page.tag, page.tag] }.append(["All Pages", "global"], ["Archivist must be true to select page access", nil, {id: "nil-value"}]).reverse()
    @submit_text = "Update User Account"
    if @user.update(account_update_params)
      flash.alert = "#{@user.email}'s account successfully updated"
      redirect_to users_path
    else
      render :edit
    end
  end

  # DELETE /resource
  def destroy
    user = User.find(params[:format])
    if user != current_user
      user.destroy
      flash.alert = "Account successfully destroyed"
    else
      flash.alert = "You cannot destroy your own account"
    end

    redirect_to users_path
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:page, :admin])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:page, :admin, :id])
  end

  # method overrides some of Devise's built-in to allow for blank password field on update
  def account_update_params
    update_params = params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :admin, :page)

    if update_params[:password].blank? && update_params[:password_confirmation].blank?
      update_params.delete(:password)
      update_params.delete(:password_confirmation)
    end

    update_params
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  def id(params)
    params.format
  end
end
