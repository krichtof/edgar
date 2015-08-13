require "rails_helper"

describe Room do
  describe "factory and validations" do
    it { expect(Room.new).to be_invalid }
    it { expect(FactoryGirl.build(:room)).to be_valid }
    it { expect(FactoryGirl.build(:room, venue_id: nil)).to be_invalid }
  end

  describe "to_csv" do
    let(:room) { FactoryGirl.create(:room) }
    let(:expected_line) {[
      room.venue.name, ExportTools.build_list(room.venue.emails), ExportTools.build_list(room.venue.phones),
      ExportTools.build_list(room.venue.addresses), ExportTools.build_list(room.venue.websites),
      room.venue.translated_kind, room.venue.residency, room.venue.accompaniment,
      room.venue.network_list, room.venue.custom_list,
      room.venue.season_months, room.venue.style_list,
      room.venue.contract_list, room.venue.discovery,
      room.venue.translated_period, room.venue.scheduling_remark,
      room.venue.prospecting_months, room.venue.remark,
      room.name, room.seating, room.standing, room.modular_space,
     "#{room.depth} x #{room.width} x #{room.height}", room.bar,
     ExportTools.build_list(room.venue.people)
    ].to_csv}

    it { expect(room.to_csv).to eq(expected_line) }

  end
end
