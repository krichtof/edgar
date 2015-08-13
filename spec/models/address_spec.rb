require "rails_helper"

describe Address do

  describe "have validations and a valid factory" do
    it { expect(FactoryGirl.build(:address)).to be_valid }
  end

  describe "full_address" do
    let(:address) { FactoryGirl.build(:address, street: '34 rue de la gare', city: 'Marseille', postal_code: '13003', more_info: 'près du piano, à coté du McDo', country: 'FR') }
    it { expect(address.full_address).to eq('34 rue de la gare, 13003 Marseille, France, près du piano, à coté du McDo') }
  end

  describe "to_s" do
    let(:address) { 
      FactoryGirl.build(:address, street: '34 rue de la gare', city: 'Marseille', postal_code: '13003', 
      more_info: 'près du piano, à coté du McDo', country: 'FR', kind: Address::MAIN_ADDRESS) 
    }
    it { expect(address.to_s).to eq("#{address.full_address} [Adresse principale]") }
  end
end
