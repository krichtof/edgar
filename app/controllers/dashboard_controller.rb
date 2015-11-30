class DashboardController < ApplicationController
  def index
    if params[:empty] == "1"
      render "empty"
    end
    @pending_tasks = Task.pending.limit(3)
  end
end