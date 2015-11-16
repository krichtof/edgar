class ApplicationController < ActionController::Base
  before_action: set_locale

  protect_from_forgery
  # before_filter :set_locale
  before_filter :set_current_tenant
  after_filter :reset_tenant
  
  helper_method :current_account
  helper_method :announcements_count

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
  
  def current_account
    Account.find(Account.current_id)
  end

  def announcements_count
    last_hit = cookies.signed[:last_hit]
    if last_hit 
      Announcement.where("published_at >= ? AND published_at <= ?", Time.at(last_hit), Time.zone.now).count
    else
      Announcement.where("published_at >= ? AND published_at <= ?", Time.zone.now - 1.week, Time.zone.now).count
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

  private
  def set_current_tenant
    account = Account.find_by_domain(request.subdomain)
    Account.current_id = account.id if account
  end

  private
  def reset_tenant
    Account.current_id = nil
  end

end
