module ApplicationHelper
  include Pagy::Frontend

  # updates path used in user registration form_with for new or edit
  def user_for_path(user)
      user.persisted? ? user_registration_path(user) : registration_path(:admin_user)
  end

  # updates method used in user registration form_with for new or edit 
  def user_form_method(user)
      user.persisted? ? :put : :post
  end
end
