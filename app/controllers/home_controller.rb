class HomeController < AppController
  def index
    if current_user.has_role? :admin
      redirect_to users_path
    else
      if !current_user.welcome_hidden?
        redirect_to welcome_path
        return
      end
      if params[:empty] == "1"
        render "empty"
      end
      @pending_tasks = Task.pending.limit(2)
    end
  end
end
