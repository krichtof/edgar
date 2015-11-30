class SubscriptionsController < ApplicationController
  skip_before_filter :check_membership, :check_plan
  force_ssl

  def new
  end
  
  def edit
  end

  def update
      amount = charge('Mise à jour vers GOLD', params)
      current_account.upgrade!

      if current_account.save
        SendUpgradeReceiptEmailWorker.perform_async(current_account.id, current_user.id, amount)
        redirect_to edit_account_path,
          notice: t('notices.subscriptions.upgrade_done', end_subscription: l(current_account.subscription_lasts_at))
      else
        redirect_to edit_account_path, notice: "Une erreur est survenue mais votre carte a bien été débitée"
      end
    rescue Stripe::CardError => e
      redirec_to new_subscription_path, notice: e.to_s
  end

  def create
      amount = charge("Adhésion #{current_account.name} #{params[:team].to_bool ? 'GOLD' : 'SOLO'}", params)
      current_account.subscribe!(params[:team].to_bool)

      if current_account.save
        SendSubscriptionReceiptEmailWorker.perform_async(current_account.id, current_user.id, amount)
        redirect_to edit_account_path, 
          notice: t('notices.subscriptions.done', end_subscription: l(current_account.subscription_lasts_at))
      else
        redirect_to new_subscription_path, notice: "Une erreur est survenue mais votre carte a bien été débitée"
      end
    rescue Stripe::CardError => e
      # The card has been declined
      redirect_to new_subscription_path, notice: e.to_s
  end

  private 

  def charge(description, params)
    amount = params[:amount]
    Stripe::Charge.create(
      :amount => (amount.to_f * 100).to_i,
      :currency => "eur",
      :source => params[:stripeToken],
      :description => description
    )
    amount
  end
end
