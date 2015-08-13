require "rails_helper"

describe Website do

  describe "have validations and a valid factory" do
    it { expect(FactoryGirl.build(:website)).to be_valid }
  end

  describe "to_s" do
    let(:website) { FactoryGirl.build(:website, url: 'http://merciedgar.com' ) }
    it { expect(website.to_s).to eq("http://merciedgar.com") }
  end
end

