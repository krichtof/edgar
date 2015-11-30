class ExportsController < ApplicationController
  def new
    @job_id = XmlExportWorker.perform_async(Account.current_id, params)
  end
end