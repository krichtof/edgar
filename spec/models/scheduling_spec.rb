require "rails_helper"

describe Scheduling do

  describe "have validations and a valid factory" do
    it { expect(FactoryGirl.build(:scheduling)).to be_valid }
  end

  describe "translated_period" do
    context "no specified period" do
      let(:scheduling) { FactoryGirl.build(:scheduling, period: nil)}
      it { expect(scheduling.translated_period).to eq(nil) }
    end
    
    context "with period" do
      let(:scheduling) { FactoryGirl.build(:scheduling, period: Scheduling::QUATERLY) }
      it { expect(scheduling.translated_period).to eq(I18n.t(scheduling.period, scope: 'simple_form.options.schedulings.period')) }
    end    
  end
  
  describe "export" do
    context "with an account with a scheduling" do
      let(:account) { FactoryGirl.create(:account) }
      let!(:buyer) { FactoryGirl.create(:show_buyer, account_id: account.id) }
      let!(:scheduling) { FactoryGirl.create(:scheduling, show_buyer: buyer) }

    it { expect(File.basename(Scheduling.export(account))).to eq("festivals-et-autres-organisateurs-de-spectacles-#{account.domain}.csv") }

    it { expect(File.readlines(Scheduling.export(account)).sort).to eq([scheduling.to_csv, Scheduling.csv_header].sort) }
    end
  end

  describe "to_csv" do
    context "with a show buyer only" do
      let(:buyer) { FactoryGirl.create(:show_buyer) }
      
      context "with period" do
        let(:scheduling) { FactoryGirl.create(:scheduling, show_buyer: buyer, show_host: nil, period: Scheduling::QUATERLY) }

        let(:expected_line) {[
          scheduling.name, I18n.t(scheduling.period, scope: 'simple_form.options.schedulings.period'), scheduling.prospecting_months, scheduling.contract_list, scheduling.style_list, scheduling.remark, scheduling.discovery, buyer.name, ExportTools.build_list(buyer.emails), ExportTools.build_list(buyer.phones), ExportTools.build_list(buyer.addresses), ExportTools.build_list(buyer.websites), buyer.network_list,buyer.custom_list, buyer.remark, ExportTools.build_list(buyer.people)
        ].to_csv}

        it { expect(scheduling.to_csv).to eq(expected_line) }
      end
      
      context "without period" do
        let(:scheduling) { FactoryGirl.create(:scheduling, show_buyer: buyer, show_host: nil, period: nil) }

        let(:expected_line) {[
          scheduling.name, scheduling.period, scheduling.prospecting_months, scheduling.contract_list, scheduling.style_list, scheduling.remark, scheduling.discovery, buyer.name, ExportTools.build_list(buyer.emails), ExportTools.build_list(buyer.phones), ExportTools.build_list(buyer.addresses), ExportTools.build_list(buyer.websites), buyer.network_list,buyer.custom_list, buyer.remark, ExportTools.build_list(buyer.people)
        ].to_csv}

        it { expect(scheduling.to_csv).to eq(expected_line) }
      end
      
    end
    
    context "with a festival only" do
      let(:festival) { FactoryGirl.create(:festival, nb_edition: 2, last_year: '1999')}
      let(:scheduling) { FactoryGirl.create(:scheduling, show_buyer: nil, show_host: festival) }
      
      let(:expected_line) {[
        scheduling.name, I18n.t(scheduling.period, scope: 'simple_form.options.schedulings.period'), scheduling.prospecting_months, scheduling.contract_list, scheduling.style_list, 
        "Nb edition : 2 / Derniere annee : 1999", 
        scheduling.discovery, festival.name, ExportTools.build_list(festival.emails), ExportTools.build_list(festival.phones), 
        ExportTools.build_list(festival.addresses), ExportTools.build_list(festival.websites), festival.network_list,festival.custom_list, 
        festival.remark, ExportTools.build_list(festival.people)
      ].to_csv} 
      
      it { expect(scheduling.organizer).to respond_to(:nb_edition) }
      it { expect(scheduling.to_csv).to eq(expected_line) }
    end        
  end

  describe "Organizer" do
    context "with a show buyer only" do
      let(:buyer) { FactoryGirl.create(:show_buyer) }
      let(:scheduling) { FactoryGirl.create(:scheduling, show_buyer: buyer, show_host: nil) }

      it { expect(scheduling.organizer).to eq(buyer) }
    end

    context "with a show host only" do
      let(:host) { FactoryGirl.create(:venue) }
      let(:scheduling) { FactoryGirl.create(:scheduling, show_buyer: nil, show_host: host) }

      it { expect(scheduling.organizer).to eq(host) }
    end

    context "with a show host and a show buyer" do
      let(:buyer) { FactoryGirl.create(:show_buyer) }
      let(:host) { FactoryGirl.create(:venue) }
      let(:scheduling) { FactoryGirl.create(:scheduling, show_buyer: buyer, show_host: host) }

      it { expect(scheduling.organizer).to eq(buyer) }
    end
  end
end
