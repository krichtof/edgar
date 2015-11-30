class ContactsImportsController < ApplicationController
  def new
    @import = ContactsImport.new
    @uploader = @import.contacts_file
    @uploader.success_action_redirect = new_with_details_contacts_import_url
  end

  def new_with_details
    if params[:key].present?
      @import = ContactsImport.new
    else
      redirect_to new_contacts_file_path
    end
  end

  def create
    @import = ContactsImport.new(params[:contacts_import])
    @import.user = current_user
    @import.account = current_account
    @import.test_mode = (params[:commit] == t('helpers.submit.contacts_import.test'))

    if @import.save
      @job_id = ContactsImportWorker.perform_async(@import.id)

      if @import.test_mode
        @job_url = job_path(@job_id)
        render "test_mode_create"
      end
    else
      @import.remove_contacts_file!
      @uploader = ContactsImport.new.contacts_file
      @uploader.success_action_redirect = new_with_details_contacts_import_url
      render "new"
    end
  end

  def update
    @import = ContactsImport.find(params[:id])
    raise "Operation impossible " if @import.user != current_user || @import.account != current_account
    @import.account = current_account
    @import.test_mode = (params[:commit] == t('helpers.submit.contacts_import.test'))
    if @import.update_attributes(params[:contacts_import])
      @job_id = ContactsImportWorker.perform_async(@import.id)

      if @import.test_mode
        @job_url = job_path(@job_id)
        render "test_mode_create"
      else
        render "create"
      end

    else
      render "edit"
    end
  end

end
