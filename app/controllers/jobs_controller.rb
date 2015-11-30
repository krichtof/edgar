class JobsController < ApplicationController
  def show
    jid = params[:id]
    logger.debug "jid: #{jid} "
    begin  
      status_container = SidekiqStatus::Container.load(jid)
      logger.debug "status: #{status_container.status.to_s} // #{status_container.at} // #{status_container.pct_complete} // #{status_container.payload}"
      render json: {:status => status_container.status, pct: status_container.pct_complete, result: status_container.payload, :message => status_container.message }      
    rescue
      render json: {:status => "job not found" }
    end
    
  end
end