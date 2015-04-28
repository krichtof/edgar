class AppController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_user
  
  def check_user
    if user_signed_in? && (!current_user.has_role? :admin)
      if ! current_user.authorized_for_domain?(request.subdomain)
        sign_out current_user
        redirect_to root_path, notice: "Vous n'avez pas le droit d'accéder à cette page"
      end
    end
  end
  
end
