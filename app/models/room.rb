# encoding: utf-8
# == Schema Information
#
# Table name: rooms
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  depth      :float
#  width      :float
#  height     :float
#  bar        :boolean
#  venue_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Room < ActiveRecord::Base
  belongs_to :venue, touch: true
  has_many :capacities, :dependent => :destroy

  validates_numericality_of :depth, :height, :width, allow_nil:true
  validates_presence_of :venue_id

  attr_accessible :capacities_attributes, :bar, :depth, :height, :name, :width, :seating, :standing, :modular_space
  accepts_nested_attributes_for :capacities, :reject_if => proc { |attributes| attributes[:nb].blank? }, allow_destroy:true

  attr_localized :depth, :height, :width

  VALID_CSV_KEYS = [:places_debout, :places_assies, :modulable, :ouverture_plateau, :profondeur_plateau, :hauteur_plateau]

  def self.from_csv(row)
    room = Room.new
    room.name = row[:nom]
    standing_nb = row.delete(:places_debout)
    if standing_nb.present? && standing_nb.is_a?(Integer) && standing_nb < Capacity::CAPACITY_MAX && standing_nb > 0
      standing_capacity = room.capacities.build(kind: :standing, nb: standing_nb)
      standing_capacity.modular = true if row.delete(:places_debout_modulable).try(:downcase) == "x"
    else
      row[:places_debout] = standing_nb if standing_nb.present?
    end
    seating_nb = row.delete(:places_assises)
    if seating_nb.present? && seating_nb.is_a?(Integer) && seating_nb < Capacity::CAPACITY_MAX && seating_nb > 0
      seating_capacity = room.capacities.build(kind: :seating, nb: seating_nb)
      seating_capacity.modular = true if row.delete(:places_assises_modulable).try(:downcase) == "x"
    else
      row[:places_assises] = seating_nb if seating_nb.present?
    end

    room.width = row.delete(:ouverture_plateau) if row[:ouverture_plateau].is_a?(Integer)
    room.depth = row.delete(:profondeur_plateau) if row[:profondeur_plateau].is_a?(Integer)
    room.height = row.delete(:hauteur_plateau) if row[:hauteur_plateau].is_a?(Integer)
    room.bar = true if row.delete(:bar_salle).try(:downcase) == "x"
    room
  end

  def to_csv
    [self.venue.name, ExportTools.build_list(self.venue.emails), ExportTools.build_list(self.venue.phones),
     ExportTools.build_list(self.venue.addresses), ExportTools.build_list(self.venue.websites),
     self.venue.translated_kind, self.venue.residency, self.venue.accompaniment,
     self.venue.network_list, self.venue.custom_list,
     self.venue.season_months, self.venue.style_list,
     self.venue.contract_list, self.venue.discovery,
     self.venue.period, self.venue.scheduling_remark,
     self.venue.prospecting_months, self.venue.remark,
     self.name, self.seating, self.standing, self.modular_space,
     "#{self.depth || '?'} x #{self.width || '?'} x #{self.height || '?'}", self.bar, ExportTools.build_list(self.venue.people)
    ].to_csv
  end


end
