class ApplicationController < ActionController::Base
  protect_from_forgery
  # before_filter :set_locale
  before_filter :set_current_tenant
  after_filter :reset_tenant

  helper_method :current_account
  helper_method :announcements_count
  # belongs to app_controller before merge
  before_filter :authenticate_user!
  before_filter :check_user
  before_filter :check_membership
  before_filter :check_plan

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def current_account
    @current_account ||= Account.find(Account.current_id)
  end

  def announcements_count
    last_hit = cookies.signed[:last_hit]
    if last_hit
      Announcement.where("published_at >= ? AND published_at <= ?", Time.at(last_hit), Time.zone.now).count
    else
      Announcement.where("published_at >= ? AND published_at <= ?", Time.zone.now - 1.week, Time.zone.now).count
    end
  end

  def check_user
    if user_signed_in? && (!current_user.has_role? :admin)
      if ! current_user.authorized_for_domain?(request.subdomain)
        sign_out current_user
        flash[:notice] = "Vous n'avez pas le droit d'accéder à cette page" if request.subdomain != 'login'
        redirect_to root_path
      end
    end
  end

  def check_membership
    if (!current_user.has_role? :admin)
      if current_account.in_trial_period?
        if current_account.trial_period_ended_in_less_than_one_week?
          flash[:notice] = t('notices.subscriptions.trial_period_lasts_soon_html',
            end_trial_period: l(current_account.trial_period_lasts_at),
            link: new_subscription_path
          ).html_safe
        elsif current_account.subscription_ended_in_less_than_one_month?
          flash[:notice] = t("notices.subscriptions.need_to_subscribe_soon_html",
            link: new_subscription_path,
            end_subscription: l(current_account.subscription_lasts_at)).html_safe
        end
      elsif current_account.subscription_up_to_date?
        if current_account.trial_period_ended_in_less_than_one_week?
          flash[:notice] = t('notices.subscriptions.trial_period_lasts_soon_html',
            end_trial_period: l(current_account.trial_period_lasts_at),
            link: new_subscription_path
          ).html_safe
        elsif current_account.subscription_ended_in_less_than_one_month?
          flash[:notice] = t("notices.subscriptions.need_to_subscribe_soon_html",
            link: new_subscription_path,
            end_subscription: l(current_account.subscription_lasts_at)).html_safe
        end
      else
        if current_account.last_subscription_at.nil?
          notice = t("notices.subscriptions.trial_period_ended")
        else
          notice = t("notices.subscriptions.not_up_to_date")
        end
        redirect_to new_subscription_path, notice: notice
      end
    end
  end

  def check_plan
    if (!current_user.has_role? :admin) && !current_account.team? && current_account.member?(current_user)
      redirect_to edit_subscription_path, notice: t('notices.subscriptions.single_user_access', account_name: current_account.name, manager_name: current_account.manager.name)
    end
  end

  private
  def set_locale
    if params[:locale].present?
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
    end
  end

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => I18n.locale }
  end

  def set_current_tenant
    account = Account.find_by_domain(request.subdomain)
    Account.current_id = account.id if account
  end

  def reset_tenant
    Account.current_id = nil
  end

end
