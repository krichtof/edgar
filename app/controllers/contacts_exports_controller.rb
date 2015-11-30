class ContactsExportsController < ApplicationController
  def new
    ExportContacts.perform_async(current_account.id, current_user.id)
    redirect_to edit_account_path, notice: I18n.t('notices.contacts_export.initiated')
  end
end
