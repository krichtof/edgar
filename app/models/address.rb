# encoding: utf-8
# == Schema Information
#
# Table name: addresses
#
#  id          :integer          not null, primary key
#  street      :string(255)
#  postal_code :string(255)
#  city        :string(255)
#  state       :string(255)
#  country     :string(255)
#  kind        :string(255)
#  contact_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  latitude    :float
#  longitude   :float
#  more_info   :text
#  account_id  :integer
#

class Address < ActiveRecord::Base
  belongs_to :contact, touch:true
  belongs_to :account
  attr_accessible :city, :country, :kind, :postal_code, :state, :street, :more_info, :latitude, :longitude, :geocoded_precisely
  acts_as_gmappable :process_geocoding => false, address: :address_for_geocode
  geocoded_by :full_address

  before_validation :format_postal_code
  before_save :set_account

  DEPARTEMENTS = {
    "01" => { name: "Ain", region_code: 22 },
    "02" => { name: "Aisne", region_code: 19 },
    "03" => { name: "Allier", region_code: 2 },
    "04" => { name: "Alpes de Haute-Provence", region_code: 21 },
    "05" => { name: "Alpes (Hautes)", region_code: 21 },
    "06" => { name: "Alpes Maritimes", region_code: 21 },
    "07" => { name: "Ardèche", region_code: 22 },
    "08" => { name: "Ardennes", region_code: 6 },
    "09" => { name: "Ariège", region_code: 14 },
    "10" => { name: "Aube", region_code: 6 },
    "11" => { name: "Aude", region_code: 11 },
    "12" => { name: "Aveyron", region_code: 14 },
    "13" => { name: "Bouches du Rhône", region_code: 21 },
    "14" => { name: "Calvados", region_code: 24 },
    "15" => { name: "Cantal", region_code: 2 },
    "16" => { name: "Charente", region_code: 20 },
    "17" => { name: "Charente Maritime", region_code: 20 },
    "18" => { name: "Cher", region_code: 5 },
    "19" => { name: "Corréze", region_code: 12 },
    "20" => { name: "Corse", region_code: 7 },
    "23" => { name: "Creuse", region_code: 12 },
    "24" => { name: "Dordogne", region_code: 1 },
    "25" => { name: "Doubs", region_code: 9 },
    "26" => { name: "Drôme", region_code: 22 },
    "27" => { name: "Eure", region_code: 17 },
    "28" => { name: "Eure et Loir", region_code: 5 },
    "29" => { name: "Finistére", region_code: 4 },
    "30" => { name: "Gard", region_code: 11 },
    "31" => { name: "Garonne (Haute)", region_code: 14 },
    "32" => { name: "Gers", region_code: 14 },
    "33" => { name: "Gironde", region_code: 1 },
    "34" => { name: "Hérault", region_code: 11 },
    "35" => { name: "Ile et Vilaine", region_code: 4 },
    "36" => { name: "Indre", region_code: 5 },
    "37" => { name: "Indre et Loire", region_code: 5 },
    "38" => { name: "Isére", region_code: 22 },
    "39" => { name: "Jura", region_code: 9 },
    "40" => { name: "Landes", region_code: 1 },
    "41" => { name: "Loir et Cher", region_code: 5 },
    "42" => { name: "Loire", region_code: 22 },
    "43" => { name: "Loire (Haute)", region_code: 2 },
    "44" => { name: "Loire Atlantique", region_code: 18 },
    "45" => { name: "Loiret", region_code: 5 },
    "46" => { name: "Lot", region_code: 14 },
    "47" => { name: "Lot et Garonne", region_code: 1 },
    "48" => { name: "Lozére", region_code: 11 },
    "49" => { name: "Maine et Loire", region_code: 18 },
    "50" => { name: "Manche", region_code: 24 },
    "51" => { name: "Marne", region_code: 6 },
    "52" => { name: "Marne (Haute)", region_code: 6 },
    "53" => { name: "Mayenne", region_code: 18 },
    "54" => { name: "Meurthe et Moselle", region_code: 13 },
    "55" => { name: "Meuse", region_code: 13 },
    "56" => { name: "Morbihan", region_code: 4 },
    "57" => { name: "Moselle", region_code: 13 },
    "58" => { name: "Niévre", region_code: 3 },
    "59" => { name: "Nord", region_code: 15 },
    "60" => { name: "Oise", region_code: 19 },
    "61" => { name: "Orne", region_code: 24 },
    "62" => { name: "Pas de Calais", region_code: 15 },
    "63" => { name: "Puy de Dôme", region_code: 2 },
    "64" => { name: "Pyrénées Atlantiques", region_code: 1 },
    "65" => { name: "Pyrénées (Hautes)", region_code: 14 },
    "66" => { name: "Pyrénées Orientales", region_code: 11 },
    "67" => { name: "Rhin (Bas)", region_code: 23 },
    "68" => { name: "Rhin (Haut)", region_code: 23 },
    "69" => { name: "Rhône", region_code: 22 },
    "70" => { name: "Saône (Haute)", region_code: 9 },
    "71" => { name: "Saône et Loire", region_code: 3 },
    "72" => { name: "Sarthe", region_code: 18 },
    "73" => { name: "Savoie", region_code: 22 },
    "74" => { name: "Savoie (Haute)", region_code: 22 },
    "75" => { name: "Paris", region_code: 10 },
    "76" => { name: "Seine Maritime", region_code: 17 },
    "77" => { name: "Seine et Marne", region_code: 10 },
    "78" => { name: "Yvelines", region_code: 10 },
    "79" => { name: "Sèvres (Deux)", region_code: 20 },
    "80" => { name: "Somme", region_code: 19 },
    "81" => { name: "Tarn", region_code: 14 },
    "82" => { name: "Tarn et Garonne", region_code: 14 },
    "83" => { name: "Var", region_code: 21 },
    "84" => { name: "Vaucluse", region_code: 21 },
    "85" => { name: "Vendée", region_code: 18 },
    "86" => { name: "Vienne", region_code: 20 },
    "87" => { name: "Vienne (Haute)", region_code: 12 },
    "88" => { name: "Vosges", region_code: 13 },
    "89" => { name: "Yonne", region_code: 3 },
    "90" => { name: "Belfort (Territoire de)", region_code: 9 },
    "91" => { name: "Essonne", region_code: 10 },
    "92" => { name: "Hauts de Seine", region_code: 10 },
    "93" => { name: "Seine Saint Denis", region_code: 10 },
    "94" => { name: "Val de Marne", region_code: 10 },
    "976" => { name: "Mayotte", region_code: 8 },
    "971" => { name: "Guadeloupe", region_code: 8 },
    "973" => { name: "Guyane", region_code: 8 },
    "972" => { name: "Martinique", region_code: 8 },
    "974" => { name: "Réunion", region_code: 8 },
    "21" => { name: "Côte d''or", region_code: 3 },
    "22" => { name: "Côtes d''armor", region_code: 4 },
    "2A" => { name: "Corse du sud", region_code: 7 },
    "2B" => { name: "Haute corse", region_code: 7 },
    "95" => { name: "Val d''oise", region_code: 10 }
  }

REGIONS = {
  1 => { name: "Aquitaine" },
  2 => { name: "Auvergne" },
  3 => { name: "Bourgogne" },
  4 => { name: "Bretagne" },
  5 => { name: "Centre" },
  6 => { name: "Champagne Ardenne" },
  7 => { name: "Corse" },
  8 => { name: "DOM/TOM" },
  9 => { name: "Franche Comté" },
  10 => { name: "Ile de France" },
  11 => { name: "Languedoc Roussillon" },
  12 => { name: "Limousin" },
  13 => { name: "Lorraine" },
  14 => { name: "Midi Pyrénées" },
  15 => { name: "Nord Pas de Calais" },
  17 => { name: "Haute Normandie" },
  18 => { name: "Pays de la Loire" },
  19 => { name: "Picardie" },
  20 => { name: "Poitou Charentes" },
  21 => { name: "Provence Alpes Côte d''azur" },
  22 => { name: "Rhône Alpes" },
  23 => { name: "Alsace" },
  24 => { name: "Basse-Normandie" }
}

  MAIN_ADDRESS = :main_address
  ADMIN_ADDRESS = :admin_address
  def set_account
    self.account_id = self.contact.account_id if self.contact.present?
  end

  def address_for_geocode
    [self.street, "#{self.postal_code} #{self.city}", Country.new(self.country).name].reject(&:blank?).join(', ')
  end

  def full_address
    [self.street, "#{self.postal_code} #{self.city}", Country.new(self.country).name, self.more_info].reject(&:blank?).join(', ')
  end

  def to_s
    "#{full_address} [#{I18n.t(kind, scope: 'simple_form.options.addresses.kind')}]"
  end

  def department_name
    @department_name ||= DEPARTEMENTS[department_code].try(:fetch,:name)
  end

  def region_code
    @region_code ||= DEPARTEMENTS[department_code].try(:fetch,:region_code)
  end

  def region_name
    @region_name ||= REGIONS[region_code].try(:fetch,:name)
  end

  def department_code
    @department_code ||= if self.postal_code && self.country
      if self.postal_code.start_with?("97")
        self.postal_code[0..2]
      else
        self.postal_code[0..1]
      end
    end
  end

  def gmaps4rails_infowindow
    self.contact.name
  end

  def self.from_csv(row)
    address = Address.new
    address.street = row.delete(:adresse)
    address.country = Country.find_country_by_names(row.delete(:pays)).try(:alpha2) || "FR"
    address.postal_code = row.delete(:code_postal)
    address.format_postal_code
    address.city = row.delete(:ville)
    address.kind = :main_address
    lat_long = GeonamesPostalCode.get_latitude_longitude_and_admin_names(city: address.city, postal_code: address.postal_code, country_code: address.country)
    if lat_long
      address.latitude = lat_long["latitude"]
      address.longitude = lat_long["longitude"]
      address.admin_name1 = lat_long["admin_name1"]
      address.admin_name2 = lat_long["admin_name2"]
    end
    address
  end

  def format_postal_code
    if self.postal_code && self.country == "FR" || country == nil
      if self.postal_code.to_s.length == 4
        self.postal_code = "0#{postal_code}"
      end
    end
  end
end
