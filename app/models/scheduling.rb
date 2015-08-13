# encoding: utf-8

# == Schema Information
#
# Table name: schedulings
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  show_host_id   :integer
#  show_host_type :string(255)
#  show_buyer_id  :integer
#  scheduler_id   :integer
#  period         :string(255)
#  contract_tags  :string(255)
#  style_tags     :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Scheduling < ActiveRecord::Base
  belongs_to :show_host, polymorphic: true, autosave: true
  belongs_to :show_buyer, autosave: true
  belongs_to :scheduler, class_name: "Person", touch: true, autosave: true
  has_many :prospectings, dependent: :destroy

  attr_accessible :name, :period, :remark, :discovery, :contract_tags, :contract_list, :style_tags, :prospecting_months, :show_buyer_name, :show_host_name, :show_host_kind, :scheduler_name, :external_show_buyer
  attr_accessor :scheduler_name

  QUATERLY = 'quaterly'
  ALL_YEAR = 'all_year'
  PER_SEMESTER = 'per_semester'

  PERIOD_LIST = [ALL_YEAR, QUATERLY, PER_SEMESTER]
  CONTRACT_LIST = %w(Co-realisation Co-production Cession Location Engagement Autre)

  validates :name, presence: true
  validates :external_show_buyer, presence: true
  validates_inclusion_of :period, in: PERIOD_LIST, allow_nil: true

  before_save :format_styles, if: "style_tags_changed?"
  before_save :set_show_buyer
  after_save :set_scheduler_function
  after_save :update_styles

  def to_s
    result = name
    result = [result, show_host.try(:name)].compact.join(" à ")
    result = [result, show_buyer.try(:name)].compact.join(" par ")
    result
  end

  def prospecting_months_s
    prospecting_months.present? ? prospecting_months.map {|m| I18n.t("date.abbr_month_names")[m.to_i]}.join('-') : "Non renseigné"
  end

  def external_show_buyer=(value)
    @external_show_buyer = value
    self.show_buyer = nil if value == "Cette structure"
  end

  def external_show_buyer
    if show_buyer.present?
      "Un autre organisateur de spectacles"
    else
      "Cette structure"
    end
  end

  def show_host_kind=(kind)
    @show_host_kind = kind
  end

  def show_host_kind
    self.show_host.class.name if self.show_host
  end

  def show_host_name=(name)
    if name.present? && name != show_host_name && @show_host_kind
      show_host_structure = Structure.joins(:contact).where(structurable_type: ["Venue","Festival"], contacts:{name: Contact.format_name(name)}).first_or_initialize
      if show_host_structure.new_record?
        self.show_host = Venue.new(structure_attributes: { contact_attributes: {name: name} }) if @show_host_kind == "Venue"
        self.show_host = Festival.new(structure_attributes: { contact_attributes: {name: name} }) if @show_host_kind == "Festival"
        self.show_host.save
      else
        self.show_host = show_host_structure.structurable
      end
    end
  end

  def show_host_name
    self.show_host.try(:name)
  end

  def show_buyer_name=(name)
    if name.present? && @external_show_buyer != "Cette structure"
      self.show_buyer = ShowBuyer.joins(:structure => :contact).where(contacts: {name: Contact.format_name(name)}).first_or_initialize
      if self.show_buyer.new_record?
        self.show_buyer.build_structure.build_contact(name: name)
        self.show_buyer.save
      end
    end
  end

  def show_buyer_name
    self.show_buyer.try(:name)
  end

  def set_show_buyer
    self.show_buyer = nil if @external_show_buyer == "Cette structure"
  end

  def scheduler_name=(name)
    if name.present?
      self.scheduler = Person.joins(:contact).where(contacts: { name: Contact.format_name(name) }).first_or_initialize
      if self.scheduler.new_record?
        scheduler.name = name
        scheduler.save
      end
    end
  end

  def scheduler_name
    self.scheduler.try(:name)
  end

  def set_scheduler_function
    if scheduler.present?
      self.show_buyer.present? ? s = self.show_buyer.structure : s = self.show_host.structure
      ps = s.people_structures.where(title:"Programmateur", person_id: scheduler.id).first_or_initialize
      if ps.new_record?
        ps.person = scheduler
        ps.save
      end
    end
  end

  def period_with_integer=(number)
    case number.to_s
    when "3"
      self.period = QUATERLY
    when "6"
      self.period = PER_SEMESTER
    when "12"
      self.period = ALL_YEAR
    else
      self.period = nil
    end
  end

  def period_with_integer
    case period
    when QUATERLY
      "3"
    when PER_SEMESTER
      "6"
    when ALL_YEAR
      "12"
    end
  end

  def making_prospecting?(m=Time.zone.now.month)
    self.prospecting_months.present? ? self.prospecting_months.include?(m.to_s) : false
  end

  def contract_list
    self.contract_tags.present? ? self.contract_tags.split(',') : []
  end

  def contract_list=(contracts)
    self.contract_tags = contracts.delete_if(&:empty?).join(',') if contracts.present?
  end

  def style_list
    self.style_tags.split(',').map(&:strip).map(&:downcase) if self.style_tags.present?
  end

  def style_list=(styles)
    self.style_tags = styles.map(&:downcase).join(', ') if styles.present?
  end

  def update_styles
    Style.add_styles(style_list) if style_tags.present?
  end

  def format_styles
    self.style_tags = self.style_tags.split(',').map(&:strip).map(&:downcase).uniq.join(',') if self.style_tags.present?
  end

  def deep_xml(builder=nil)
    to_xml(builder: builder, :skip_instruct => true, :skip_types => true, except: [:id, :created_at, :updated_at, :scheduler_id, :show_host_id, :show_host_type, :show_buyer_id])  do |xml|
      xml.scheduler_name scheduler_name if scheduler_id
      xml.show_buyer_name show_buyer_name if show_buyer_id
    end
  end

  def self.from_merciedgar_hash(scheduling_attributes, imported_at)
    show_buyer_name = scheduling_attributes.delete("show_buyer_name")
    show_host_name = scheduling_attributes.delete("show_host_name")
    scheduler_name = scheduling_attributes.delete("scheduler_name")

    prospecting_months = scheduling_attributes.delete("prospecting_months")
    if prospecting_months
      pmonths = prospecting_months.delete("prospecting_month")
      pmonths = [].push(pmonths.to_s) unless pmonths.is_a?(Array)
    end
    scheduling = Scheduling.new(scheduling_attributes)
    scheduling.show_buyer = Contact.where("name = ? or name LIKE ?", show_buyer_name, "#{show_buyer_name} #%").where(imported_at: imported_at).first.try(:fine_model) if show_buyer_name
    scheduling.scheduler = Contact.where("name = ? or name LIKE ?", scheduler_name, "#{scheduler_name} #%").where(imported_at: imported_at).first.try(:fine_model) if scheduler_name
    scheduling.prospecting_months = pmonths
    scheduling
  end

  def self.from_csv(row)
    scheduling = Scheduling.new
    scheduling.name = "Programmation principale"

    period_with_integer = row.delete(:cycle_de_programmation)
    if period_with_integer
      scheduling.period_with_integer = period_with_integer
      row[:cycle_de_programmation] =  period_with_integer unless scheduling.period_with_integer
    end

    scheduling.style_tags = row.delete(:styles)

    contract_tags = row.delete(:contrats)
    if contract_tags.present?
      contract_tags_array = contract_tags.split(',').map(&:strip)
      (contract_tags_array - CONTRACT_LIST).empty? ? scheduling.contract_tags = contract_tags_array.join(',') : row[:contrats] = contract_tags
    end

    discovery = row["decouverte".to_sym]
    if discovery.present?
      if discovery.try(:downcase) == "x"
        scheduling.discovery = true
        row.delete("decouverte".to_sym)
      end
    end

    scheduling.remark = row.delete(:observations_programmation)
    prospecting_months_string = row.delete("mois_prospection".to_sym)
    if prospecting_months_string
      begin
        scheduling.prospecting_months = prospecting_months_string.split(',').map do |e|
          if e.count('.') == 2
            elements = e.strip.split('..')
            Range.new(elements[0].to_i, elements[1].to_i).to_a.map(&:to_s)
          else
            e.strip
          end
        end.flatten
      rescue
        scheduling.prospecting_months = nil
        row["mois_prospection".to_sym] = prospecting_months_string
      end
    end
    scheduler_name = row[:nom_programmateur]
    if scheduler_name
      if scheduler_name.length > 1 && scheduler_name.split(' ').count > 1
        scheduler_hash = row.select{|k| k.to_s.end_with?("_programmateur")}
        scheduler_hash.keys.each do |k|
          scheduler_hash[k.to_s.sub("_programmateur","").to_sym] = scheduler_hash.delete(k)
          row.delete(k)
        end
        scheduler_hash.merge!({  nom: scheduler_name, imported_at: row[:imported_at], first_name_last_name_order: row[:first_name_last_name_order] })
        scheduling.scheduler = Person.from_csv(scheduler_hash)
      else
        row[:nom_programmateur] = scheduler_name
      end
    end

    scheduling
  end

  def self.csv_header
    ['Nom programmation', 'Cycle de programmation', 'Mois de prospection', 'Types de contrat', 'Styles', 'Observations Programmation', 'Scene découverte',
     'Nom', 'Emails', 'Téls', 'Adresses', 'Sites web', 'Réseaux', 'Tag Perso', 'Commentaires', 'Personnes'].to_csv
  end

  def self.export(account)
    schedulings = Scheduling.includes(:show_buyer).where(show_buyers: {account_id: account.id})
    schedulings.concat(Venue.includes(:schedulings).where(account_id: account.id).map(&:schedulings).flatten)
    schedulings.concat(Festival.includes(:schedulings).where(account_id: account.id).map(&:schedulings).flatten)
    schedulings.uniq!

    return nil if schedulings.empty?

    f = File.new("festivals-et-autres-organisateurs-de-spectacles-#{account.domain}.csv", "w")
    File.open(f, 'w') do |file|
      file.puts csv_header
      schedulings.each do |s|
        file.puts s.to_csv
      end
    end
    f
  end
  
  def translated_period
    return nil unless self.period.present?
    I18n.t(self.period, scope: 'simple_form.options.schedulings.period')
  end

  def to_csv
    if show_host.respond_to?(:nb_edition) && show_host.respond_to?(:last_year)
      remark_array = [ self.remark ]
      remark_array.append("Nb edition : #{show_host.nb_edition}") 
      remark_array.append("Derniere annee : #{show_host.last_year}") 
      self.remark = remark_array.compact.join(' / ')
    end
    [self.name, translated_period, self.prospecting_months, self.contract_list, self.style_list, self.remark, self.discovery, self.organizer.name, ExportTools.build_list(self.organizer.emails), ExportTools.build_list(self.organizer.phones), ExportTools.build_list(self.organizer.addresses), ExportTools.build_list(self.organizer.websites), self.organizer.network_list,self.organizer.custom_list, self.organizer.remark, ExportTools.build_list(self.organizer.people)
    ].to_csv
  end

  def organizer
    return show_host if show_buyer.nil?
    show_buyer
  end
end
