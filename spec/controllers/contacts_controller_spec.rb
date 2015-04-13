require 'rails_helper'

describe ContactsController do
  context "with a logged user" do
    let(:user) { FactoryGirl.create(:user, label_name: "truc") }

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end

    describe "GET 'index'" do
      before(:each) { get 'index' }
      it { expect(response).to be_success }
    end

  end
end
