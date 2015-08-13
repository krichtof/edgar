# == Schema Information
#
# Table name: venues
#
#  id            :integer          not null, primary key
#  kind          :string(255)
#  start_season  :integer
#  end_season    :integer
#  residency     :boolean
#  accompaniment :boolean
#  avatar        :string(255)
#  account_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Venue < ActiveRecord::Base
  include Contacts::Xml
  default_scope { where(:account_id => Account.current_id) }

  attr_accessible :kind, :residency, :accompaniment, :season_months, :structure_attributes, :schedulings_attributes, :rooms_attributes, :network_tags, :avatar, :remote_avatar_url

  has_one :structure, as: :structurable, dependent: :destroy
  accepts_nested_attributes_for :structure

  has_many :schedulings, as: :show_host, dependent: :destroy, order: "id ASC"
  has_many :show_buyers, through: :schedulings, uniq: true
  accepts_nested_attributes_for :schedulings, :reject_if => :all_blank, :allow_destroy => true

  has_many :rooms, :dependent => :destroy
  accepts_nested_attributes_for :rooms, :reject_if => :all_blank, :allow_destroy => true

  belongs_to :account

  delegate :name, :contact, :people, :tasks, :reportings, :remark, :addresses, :emails, :phones, :websites, :city, :address, :network_list, :custom_list, :contacted?, :favorite?, :main_person, to: :structure

  VENUE_KINDS = [:bar, :theater_cafe, :mjc, :music_venue, :smac, :theater, :cultural_center, :other]

  mount_uploader :avatar, AvatarUploader

  before_save :set_contact_criteria

  scope :by_type, (lambda do |kind|
    where(kind: kind) if kind.present?
  end)

  scope :capacities_less_than, (lambda do |nb|
    joins(:rooms => :capacities).where("capacities.nb <= ?", nb).uniq
  end)

  scope :capacities_more_than, (lambda do |nb|
    joins(:rooms => :capacities).where("capacities.nb >= ?", nb).uniq
  end)

  scope :capacities_between, (lambda do |nb1,nb2|
    joins(:rooms => :capacities).where("capacities.nb BETWEEN ? AND ? ", nb1,nb2).uniq
  end)

  scope :by_contract, lambda { |tag_name| joins(:schedulings).where("schedulings.contract_tags LIKE ?", "%#{tag_name}%") }
  scope :by_style, lambda { |tag_name| joins(:schedulings).where("schedulings.style_tags LIKE ?", "%#{tag_name}%") }

  scope :making_prospecting, lambda { |month| joins(:schedulings => :prospectings).where("prospectings.start_month <= ? AND prospectings.end_month >= ?",month,month) }

  CAPACITY_RANGE_OPTIONS = ["< 100", "100-400","400-1200","> 1200"]

  def to_s
    name
  end

  def fine_model
    self
  end

  def set_contact_criteria
    self.build_structure unless structure.present?
    self.structure.build_contact unless structure.contact.present?
    contact = structure.contact

    c_style_list = self.style_list
    contact.style_tags = c_style_list.join(',') if c_style_list.present?

    c_contract_list = self.contract_list
    contact.contract_tags = c_contract_list.join(',') if c_contract_list.present?

    c_capacity_tags = self.capacity_tags
    contact.capacity_tags = c_capacity_tags.join(',') if c_capacity_tags.present?

    contact.venue_kind = self.kind if self.kind.present?
  end

  def venue_must_have_at_least_one_address
    if self.addresses.blank?
      errors.add(:addresses, "A venue must have at least one address")
    end
  end

  def venue_name_must_be_unique_by_city
    if addresses.any? && addresses.first.city
      unless Venue.joins(:addresses).where(:addresses => {:city => addresses.first.city, :country => addresses.first.country}, :contacts => {:name => name}).blank?
        logger.debug "city #{addresses.first.city}"
        errors.add(:name, :taken, city: addresses.first.city)
      end
    end
  end

  def to_param
    [id, name.try(:parameterize)].compact.join('-')
  end

  def capacities
    cap = []
    self.rooms.each{|r| cap << r.capacities}
    cap.flatten
  end

  def capacity_tags
    tags = []
    seats = self.rooms.map{|r| [r.seating, r.standing]}.flatten.sort.uniq
    seats.sort.each do |qty|
      next if qty == 0
      if qty < 100
        tags << '< 100'
      elsif qty >= 100 && qty <= 400
        tags << '100-400'
      elsif qty > 400 && qty <= 1200
        tags << '401-1200'
      else
        tags << '> 1200'
      end
    end
    tags.uniq
  end

  def season
    season_months.present? ? season_months.map {|m| I18n.t("date.abbr_month_names")[m.to_i] if m.present? }.compact.join(' - ') : "Non renseigné"
  end

  def services
    services = []
    services << "Accompagnement" if self.accompaniment
    services << "Résidence" if self.residency
    services.present? ? services.join(', ') : "Non renseigné"
  end

  def contract_list
    cl = []
    self.schedulings.each do |s|
      s.contract_list.each do |c|
        cl.push(c) unless cl.include?(c)
      end
    end
    cl
  end

  def style_list
    sl = []
    self.schedulings.each do |s|
      s.style_list.each do |style|
        sl.push(style) unless sl.include?(style)
      end if s.style_list.present?
    end
    sl
  end


  def self.from_merciedgar_hash(venue_attributes, imported_at, custom_tags)
    avatar_attributes = venue_attributes.delete("base64_avatar")
    structure_attributes = venue_attributes.delete("structure")
    structure = Structure.from_merciedgar_hash(structure_attributes, imported_at, custom_tags)
    schedulings_attributes = venue_attributes.delete("schedulings")
    season_months = venue_attributes.delete("season_months")
    if season_months
      smonths = season_months.delete("season_month")
      smonths = [].push(smonths.to_s) unless smonths.is_a?(Array)
    end

    venue = Venue.new(venue_attributes)
    venue.structure = structure
    venue.upload_base64_avatar(avatar_attributes)
    venue.season_months = smonths

    if schedulings_attributes.present? && schedulings_attributes["scheduling"].present?
      if schedulings_attributes["scheduling"].is_a?(Hash)
        venue.schedulings << Scheduling.from_merciedgar_hash(schedulings_attributes["scheduling"], imported_at)
      else
        schedulings_attributes["scheduling"].each do |scheduling_attributes|
          venue.schedulings << Scheduling.from_merciedgar_hash(scheduling_attributes, imported_at)
        end
      end
    end
    venue

  end

  def self.from_xml(xml)
    attributes = Hash.from_xml(xml)
    venue_attributes = attributes["venue"]
    self.from_merciedgar_hash(venue_attributes, Time.now)
  end

  def self.from_csv(row)
    venue = Venue.new
    kind = row["type_lieu".to_sym]

    if kind.present?
      VENUE_KINDS.each do |k|
        if kind.downcase == I18n.t(k, scope: "simple_form.options.venue.kind").downcase
          venue.kind = k
          row.delete("type_lieu".to_sym)
          break
        end
      end
      venue.kind = :other unless venue.kind
    end

    venue.residency = true if row.delete("residence".to_sym).try(:downcase) == "x"
    venue.accompaniment = true if row.delete("accompagnement".to_sym).try(:downcase) == "x"
    season_months_string = row.delete("saison".to_sym)
    if season_months_string
      begin
        venue.season_months = season_months_string.split(',').map do |e|
          if e.count('.') == 2
            elements = e.strip.split('..')
            Range.new(elements[0].to_i, elements[1].to_i).to_a.map(&:to_s)
          else
            e.strip
          end
        end.flatten
      rescue
        venue.season_months = nil
        row["saison".to_sym] = season_months_string
      end
    end
    scheduling = Scheduling.from_csv(row)
    venue.schedulings << scheduling if scheduling
    venue.save
    venue.rooms << Room.from_csv(row) if (row.keys & Room::VALID_CSV_KEYS).any?
    venue.save
    venue.structure, invalid_keys = Structure.from_csv(row)

    venue.save
    [venue, invalid_keys]
  end

  def self.csv_header
    "Nom, Emails, Tels, Adresses, Sites web, Type, Residence, Accompagnement, Réseaux, Tags perso, Saison, Style, Contrats, Découverte, Période, Observations Programmations, Mois de prospection, Observations, Nom Salle, Places assises, Places debout, Modulable, Dimension Plateau (PxLxH), Bar, Personnes".split(',').to_csv
  end

  def self.export(account)
    rooms = Room.includes(:venue).where(venues: {account_id: account.id})
    return nil if rooms.empty?

    f = File.new("lieux-#{account.domain}.csv", "w")
    File.open(f, 'w') do |file|
      file.puts csv_header
      rooms.each do |room|
        file.puts room.to_csv
      end
    end
    f
  end

  def discovery
    self.schedulings.first.discovery if self.schedulings.any?
  end

  def period
    self.schedulings.first.period if self.schedulings.any?
  end
  
  def translated_period
    self.schedulings.first.translated_period if self.schedulings.any?
  end

  def scheduling_remark
    self.schedulings.first.remark if self.schedulings.any?
  end

  def prospecting_months
    self.schedulings.first.prospecting_months if self.schedulings.any?
  end
  
  def translated_kind
    return nil unless self.kind.present?
    I18n.t(self.kind, scope: 'simple_form.options.venue.kind')
  end
  
  
end
