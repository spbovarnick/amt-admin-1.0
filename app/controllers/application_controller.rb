class ApplicationController < ActionController::Base

  protected

  def authorize_global_admin
      if !current_user.admin
          redirect_to archive_items_path
      end
  end

  
  include Pagy::Backend
end
