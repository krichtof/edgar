require 'rails_helper'

describe HomeController do

  context "with a logged admin user" do
    let(:user) { FactoryGirl.create(:admin, label_name: "truc") }
    
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end

    describe "GET index" do
      before(:each) { get 'index' }
      it { expect(response).to redirect_to(users_path) }
    end
  end

  context "with a logged  user that never see welcome" do
    let(:user) { FactoryGirl.create(:user, label_name: "truc") }

    before(:each) do
      @request.host = 'truc.localhost.com'
      @request.env["devise.mapping"] = Devise.mappings[:user]
      account = FactoryGirl.build(:account, domain: 'truc')
      user.accounts = [account]
      user.save!
      FactoryGirl.build(:abilitation, user: user, account: account)
      sign_in user
    end

    describe "GET index" do
      let!(:pending_task) { FactoryGirl.create(:task) }
      before(:each) { get 'index' }
      it { expect(response).to redirect_to(welcome_path) }
    end
  end

  context "with a logged  user that already seen welcome" do
    let(:user) { FactoryGirl.create(:user, label_name: "truc", welcome_hidden: true) }

    before(:each) do
      @request.host = 'truc.localhost.com'
      @request.env["devise.mapping"] = Devise.mappings[:user]
      account = FactoryGirl.build(:account, domain: 'truc')
      user.accounts = [account]
      user.save!
      FactoryGirl.build(:abilitation, user: user, account: account)
      sign_in user
    end

    describe "GET index" do
      let!(:pending_task) { FactoryGirl.create(:task) }
      # TODO WHY WE NEED THIS EMPTY PARAMS ?????
      before(:each) { get 'index', empty: 1 }
      it { expect(response).to be_success }
    end
  end

end
