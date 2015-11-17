require 'rails_helper'

describe AccountsController do
  before(:each) do
    @request.host = "#{account.domain}.lvh.me"
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end
  
  context "with a manager" do
    let(:account) { FactoryGirl.create(:account)}
    let(:user) { FactoryGirl.create(:user, account: account, manager: true) }
    describe "GET 'edit'" do
      before(:each) { get :edit }
      it { expect(response).to be_success }
      it { expect(assigns(:account)).to eq(account) }
    end
    
  end

end
