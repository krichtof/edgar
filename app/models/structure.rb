# == Schema Information
#
# Table name: structures
#
#  id                :integer          not null, primary key
#  structurable_id   :integer
#  structurable_type :string(255)
#  avatar            :string(255)
#  account_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Structure < ActiveRecord::Base
  include Contacts::Xml
  default_scope { where(:account_id => Account.current_id) }

  attr_accessible :contact_attributes, :avatar, :remote_avatar_url, :kind

  has_one :contact, as: :contactable, dependent: :destroy
  accepts_nested_attributes_for :contact

  belongs_to :structurable, polymorphic: true

  has_many :relatives, dependent: :destroy

  has_many :people_structures
  has_many :people, through: :people_structures, uniq:true, dependent: :destroy

  delegate :name, :tasks, :reportings, :addresses, :remark, :emails, :phones, :websites, :city, :country,  :address, :phone_number, :website, :website_url, :network_list, :custom_list, :contacted?, :favorite?, to: :contact
  # delegate :avatar, to: :structurable

  mount_uploader :avatar, AvatarUploader

  validates_presence_of :contact
  # validates_associated :contact


  def kind
    fm = self.fine_model
    if fm.present?
      fm.class.name.underscore
    end
  end
  
  def kind=(k)
    unless structurable.present?
      case k
      when "venue"
        v = Venue.new
        self.structurable = v
        v.structure = self
        
      when "festival"
        f = Festival.new
        self.structurable = f
        f.structure = self
      when "show_buyer"
        s = ShowBuyer.new
        self.structurable = s
        s.structure = self 
      end
    end 
  end

  def fine_model
    self.structurable.present? ? self.structurable.fine_model : self
  end

  def add_person(first_name,last_name,title)
    p = Person.find_or_initialize_by_first_name_and_name(first_name:first_name,name:last_name)
    ps = self.people_structures.build
    ps.person = p
    ps.title = title.titleize
    ps.save
  end

  def main_person(user)
    if self.people.any?
      self.relative(user).present? ? self.relative(user).person : self.people.first
    end
  end

  def set_main_person(user,person)
    rel = relative(user) || self.relatives.build(user: user)
    rel.person = person
    rel.save
  end


  def main_person?(user,person)
    person == self.main_person(user)
  end

  def relative(user)
    relative = self.relatives.where(user_id: user.id).first
  end

  def deep_xml(builder=nil)
    to_xml(
      :builder => builder, :skip_instruct => true, :skip_types => true, 
      except: [:id, :created_at, :updated_at, :account_id, :avatar, :structurable_type, :structurable_id]
      ) do |xml|
      contact.deep_xml(xml)
      xml.people do
        people_structures.each do |ps|
          xml.person do
            xml.last_name ps.person.last_name
            xml.first_name ps.person.first_name
            xml.title ps.title
          end
        end
      end
      xml.base64_avatar do
        xml.filename self.avatar.file.filename 
        xml.content self.base64_avatar
      end  unless self.avatar_url == self.avatar.default_url
      
    end    
  end

  def self.from_merciedgar_hash(structure_attributes, imported_at, custom_tags)  
    avatar_attributes = structure_attributes.delete("base64_avatar")
    
    contact_attributes = structure_attributes.delete("contact")

    people_attributes = structure_attributes.delete("people")

    structure = Structure.new(structure_attributes)

    people_array = people_attributes["person"]
    
    if people_array.is_a?(Array)
      people_array.each do |person_hash|
        person = Person.find_or_initialize_by_first_name_and_last_name(person_hash["first_name"],person_hash["last_name"])
        if person.new_record?
          person.build_contact.imported_at = imported_at
        else
          old_person = person
          duplicates = Contact.where("name = ? OR name LIKE ?",person.name,"#{person.name} #%")
          nb_duplicates = duplicates.size
          person = duplicates.where(imported_at: imported_at).first.try(:fine_model)
          unless person
            first_name = "#{person_hash["first_name"]} ##{nb_duplicates + 1}"
            
            person = Person.new(last_name:person_hash["last_name"], first_name: first_name)
            person.build_contact.imported_at = imported_at
            person.contact.duplicate = old_person.contact
            person.contact.add_custom_tags(custom_tags)
          end
        end
        ps = structure.people_structures.build
        ps.person = person
        ps.title = person_hash["title"]
      end   
    else
      if people_array.is_a?(Hash)
        person_hash = people_array
        person = Person.find_or_initialize_by_first_name_and_last_name(person_hash["first_name"],person_hash["last_name"])
        if person.new_record?
          person.build_contact.imported_at = imported_at
        else
          old_person = person
          duplicates = Contact.where("name = ? OR name LIKE ?",person.name,"#{person.name} #%")
          nb_duplicates = duplicates.size
          person = duplicates.where(imported_at: imported_at).first.try(:fine_model)
          unless person
            first_name = "#{person_hash["first_name"]} ##{nb_duplicates + 1}"
            
            person = Person.new(last_name:person_hash["last_name"], first_name: first_name)
            person.build_contact.imported_at = imported_at
            person.contact.duplicate = old_person.contact
            person.contact.add_custom_tags(custom_tags)
          end
        end
        ps = structure.people_structures.build
        ps.person = person
        ps.title = person_hash["title"]
      end
    end
      

    
    contact = Contact.new_from_merciedgar_hash(contact_attributes, imported_at, custom_tags)
    structure.contact = contact
    structure.upload_base64_avatar(avatar_attributes)
    structure
  end
end
