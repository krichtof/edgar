class AccountsController < ApplicationController
  def create
  end
  def edit
    @account = Account.find(Account.current_id)
  end

  def update
    @account = Account.find(Account.current_id)
    if @account.update_attributes(params[:account])
      redirect_to root_path, notice:"Chouette"
    else
      render :edit
    end
  end

  def import_samples
    @job_id = SamplesImportWorker.perform_async(Account.current_id)
    render 'contacts/import_samples'
  end

  def destroy_test_contacts
    account = Account.find(Account.current_id)
    account.destroy_test_contacts
    redirect_to contacts_path
  end

end
