# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  avatar                 :string(255)
#

class User < ActiveRecord::Base
  rolify
  # has_and_belongs_to_many :accounts
  has_many :accounts, through: :abilitations
  has_many :abilitations, dependent: :destroy

  accepts_nested_attributes_for :accounts
  validates_associated :accounts

  validates_presence_of :label_name

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :accounts_attributes, :avatar, :label_name

  has_many :favorite_contacts
  has_many :favorites, through: :favorite_contacts, source: :contact


  mount_uploader :avatar, AvatarUploader

  after_create :add_user_to_mailchimp
  before_destroy :remove_user_from_mailchimp

  # override Devise method
  # no password is required when the account is created; validate password when the user sets one
  validates_confirmation_of :password
  def password_required?
    if !persisted?
      !(password != "")
    else
      !password.nil? || !password_confirmation.nil?
    end
  end

  # override Devise method
  def confirmation_required?
    false
  end

  # override Devise method
  def active_for_authentication?
    confirmed? || confirmation_period_valid?
  end

  def send_reset_password_instructions
    if self.confirmed?
      super
    else
      errors.add :base, "You must receive an invitation before you set your password."
    end
  end

  # new function to set the password
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    p[:label_name] = params[:label_name] unless self.label_name.present?
    p[:name] = params[:name]
    p[:first_name] = params[:first_name]
    p[:last_name] = params[:last_name]

    update_attributes(p)
  end

  # new function to determine whether a password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end

  # new function to provide access to protected method pending_any_confirmation
  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end

  def authorized_for_domain?(domain_name)
    self.has_role?(:admin) || self.accounts.map{|a| a.domain}.include?(domain_name)
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end


  def add_to_favorites(contact)
    fav = self.favorite_contacts.build
    fav.contact = contact
  end

  def remove_to_favorites(contact)
    fav = self.favorite_contacts.where(contact_id:contact.id).first
    self.favorite_contacts.destroy(fav) if fav
  end

  def display_name
    if self.first_name.present?
      [self.first_name,self.last_name].compact.join(' ')
    else
      self.email
    end
  end

  def to_s
    display_name
  end

  def nickname
    display_name.truncate(8, omission:"...")
  end

  def current_abilitation
    self.abilitations.where(account_id: Account.current_id).first
  end

  def send_abilitation_instructions(account,manager)
    self.generate_confirmation_token!
    UserMailer.abilitation_instructions(account,manager,self).deliver
  end

  def send_abilitation_notification(account, manager)
    UserMailer.abilitation_notification(account, manager, self).deliver
  end

  def label_name
    if self.accounts.any?
      @label_name = self.accounts.first.name
    end
    @label_name
  end

  def label_name=(label)
    @label_name = label
  end

  private

  def add_user_to_mailchimp
    return if email.include?(ENV['ADMIN_EMAIL'])
    mailchimp = Gibbon::API.new
    result = mailchimp.list_subscribe({
      :id => ENV['MAILCHIMP_LIST_ID'],
      :email_address => self.email,
      :double_optin => false,
      :update_existing => true,
      :send_welcome => true
      })
    Rails.logger.info("Subscribed #{self.email} to MailChimp") if result
  rescue Gibbon::MailChimpError => e
    Rails.logger.info("MailChimp subscribe failed for #{self.email}: " + e.message)
  end

  def remove_user_from_mailchimp
    mailchimp = Gibbon::API.new
    result = mailchimp.list_unsubscribe({
      :id => ENV['MAILCHIMP_LIST_ID'],
      :email_address => self.email,
      :delete_member => true,
      :send_goodbye => false,
      :send_notify => true
      })
    Rails.logger.info("Unsubscribed #{self.email} from MailChimp") if result
  rescue Gibbon::MailChimpError => e
    Rails.logger.info("MailChimp unsubscribe failed for #{self.email}: " + e.message)
  end

end
