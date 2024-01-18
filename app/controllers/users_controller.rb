class UsersController < ApplicationController
    layout 'admin'
    before_action :authenticate_user!, only: [:index]
    before_action :authorize_global_admin

    def index
        @users = User.all
    end

end