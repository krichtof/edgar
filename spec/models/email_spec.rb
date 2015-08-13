require "rails_helper"

describe Email do

  describe "have validations and a valid factory" do
    it { expect(FactoryGirl.build(:email)).to be_valid }
  end

  describe "to_s" do
    context "with predetermined kind email" do
      let(:email) { FactoryGirl.build(:email, address: 'stephane@laposte.net', kind: Email::WORK) }
      it { expect(email.to_s).to eq("stephane@laposte.net [#{I18n.t(Email::WORK, scope: 'simple_form.options.emails.classic_kind') }]") }
    end
  
    context "with other kind phone" do
      let(:email) { FactoryGirl.build(:email, address: 'fede-sud@mouvementrural.org', kind: 'Alpes du Sud') }
      it { expect(email.to_s).to eq("fede-sud@mouvementrural.org [Alpes du Sud]") }
    end
  end
  
end
