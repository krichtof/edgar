require 'rails_helper'

describe CampaignsController, :type => :controller do

  context "with a logged user" do

    let(:user) { FactoryGirl.create(:user, label_name: "truc") }

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end

    context "with an existing campaign" do
      let!(:campaign) { FactoryGirl.create(:campaign) }

      describe "GET index" do
        before(:each) { get :index }
        it { expect(response).to be_success }
        it { expect(assigns(:campaigns)).to eq([campaign]) }
      end

      describe "GET show" do
        before(:each) {get :show, id: campaign.id}
        it { expect(response).to be_success }
        it { expect(assigns(:campaign)).to eq(campaign) }
      end

      describe "GET edit" do
        before(:each) { get :edit, id: campaign.id }
        it { expect(response).to be_success }
        it { expect(assigns(:campaign)).to eq(campaign) }
      end

      describe "DELETE destroy" do
        before(:each) { delete :destroy, id: campaign.id }
        it { expect(Campaign.count).to eq(0) }
        it { expect(response).to redirect_to(campaigns_url) }
      end
    end

    describe "GET new" do
      before(:each) {get :new}
      it { expect(response).to be_success }
      it { expect(assigns(:campaign)).to be_a_new(Campaign)}
    end

    describe "POST create" do
      before(:each) { post :create }

      it { expect(response).to redirect_to(Campaign.last) }
      it { expect(Campaign.count).to eq(1) }
      it { expect(assigns(:campaign)).to be_a(Campaign)}
      it { expect(assigns(:campaign)).to be_persisted }
    end

  end
end
