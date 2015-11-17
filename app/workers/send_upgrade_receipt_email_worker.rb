class SendUpgradeReceiptEmailWorker
  include SidekiqStatus::Worker

  def perform(account_id, user_id, amount)
    account = Account.find(account_id)
    manager = User.find(user_id)
    UserMailer.upgrade_receipt_email(account, manager, amount).deliver
  end

end
