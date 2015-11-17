require 'zip'

# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  domain     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Account < ActiveRecord::Base
  has_many :users, through: :abilitations, uniq: true
  has_many :projects
  has_many :abilitations, dependent: :destroy
  # has_and_belongs_to_many :users

  has_many :contacts
  attr_accessible :domain, :name
  validates_presence_of :name
  validates_uniqueness_of :domain
  validates_format_of :domain, :with => /\A[a-z0-9]*\z/
  validates_exclusion_of :domain, :in => ['www','blog','mail','ftp']
  before_validation :set_domain_name
  before_validation :ensure_domain_uniqueness, :on => :create
  
  SOLO_PRICE = 20
  TEAM_PRICE = 50
  COMPLEMENT_PRICE = 30

  OPENING_SUBSCRIPTION_DAY = Date.parse(ENV["OPENING_SUBSCRIPTION_DAY"])

  scope :featured, order("contacts_count DESC")

  def to_s
    self.name
  end

  def set_domain_name
    if domain_changed?
      domain = domainnize(domain)
    end
  end

  def ensure_domain_uniqueness
    if self.domain.blank?
      self.domain = domainnize(self.name)
    end
    num = 2
    while (Account.find_by_domain(self.domain).present?)
      self.domain = "#{self.domain}#{num}"
      num += 1
    end
  end

  def domainnize(str)
    I18n.transliterate(str).delete("^a-zA-Z0-9").downcase if str.present?
  end

  def self.current_id=(id)
    Thread.current[:account_id] = id
  end

  def self.current_id
    Thread.current[:account_id] ||= 0
  end

  def mystrip(value)
    if value.present? && (value == "-" || value.length < 3)
      value = nil
    end
    value
  end


  def add_contact(title, params,venue)
    name = params[title].titleize if mystrip(params[title]).present?
    if name && name.length > 1
      name_words = name.split(" ")
      if name_words.count == 1
        fn = nil
        ln = name
      else
        fn = name.match(/(.*) (.*)/)[1]
        ln = name.match(/(.*) (.*)/)[2]
      end

      if !venue.add_person(fn,ln,title.titleize)
        logger.debug "Problem importing #{p.name} as #{ps.title} in #{venue.name} venue \n"
      end
    end
  end

  def member?(user)
    self.abilitations.where(user_id: user.id).first.member?
  end

  def manager?(user)
    first_abilitation = self.abilitations.where(user_id: user.id).first
    first_abilitation && first_abilitation.manager?
  end
  
  def manager
    abilitation = self.abilitations.where(kind: 'manager').try(:first)
    manager = abilitation.user
  end
  
  def empty
    Venue.destroy_all
    Festival.destroy_all
    ShowBuyer.destroy_all
    Structure.destroy_all
    Person.destroy_all
  end

  def destroy_test_contacts
    return nil unless self.test_imported_at
    Contact.imported_at(self.test_imported_at).find_each do |contact|
      fm = contact.fine_model
      fm.destroy
    end
  end

  def export_filename
    today = DateTime.now
    File.join(Dir.tmpdir, "#{domain}-#{today.strftime('%d%m%Y')}.zip")
  end

  def export_contacts
    File.delete(export_filename) if File.exists?(export_filename)
    Zip::File.open(export_filename, Zip::File::CREATE) do |zipfile|

      [Person, Venue, Scheduling, Structure].each do |element|
        if file = element.export(self)
          zipfile.add(File.basename(file), File.absolute_path(file))
        end
      end
    end
    export_filename
  end
  
  def trial_period_ended?
    return !in_trial_period?
  end
  
  def trial_period_lasts_at
    if (self.created_at.to_date < Date.current - 1.month) && (Date.current < OPENING_SUBSCRIPTION_DAY)
      return OPENING_SUBSCRIPTION_DAY
    end
  
    self.created_at.to_date + 1.month
  end
  
  def in_trial_period?
    return true if (Date.current < OPENING_SUBSCRIPTION_DAY) && (self.last_subscription_at.nil?)
    self.created_at > Date.current - 1.month
  end
  
  def trial_period_ended_in_less_than_one_week?
    return false unless in_trial_period?
    Date.current > self.trial_period_lasts_at - 1.week 
  end

  def subscription_up_to_date?
    return true if in_trial_period?
    self.last_subscription_at.present? && self.subscription_lasts_at > Date.current
  end
  
  def subscription_lasts_at
    return nil if self.last_subscription_at.nil?
    self.last_subscription_at + 1.year
  end
  
  def subscription_ended_in_less_than_one_month?
    subscription_lasts_at < ( Date.current + 1.month) unless in_trial_period?
  end

  def subscription_ended_in_less_than_one_week?
    subscription_lasts_at < ( Date.current + 1.week) unless in_trial_period?
  end

  def plan
    if self.team
      I18n.t('account.team_plan')
    else
      I18n.t('account.solo_plan')
    end
  end

  def subscribe!(team=false)
    self.last_subscription_at = Date.current
    self.team = team
  end

  def upgrade!
    self.team = true
  end
end
