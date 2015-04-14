require 'rails_helper'

describe OpportunitiesController do

  context "with a logged user" do

    let(:user) { FactoryGirl.create(:admin, label_name: "truc") }

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end

    context "with an existing opportunity" do
      let!(:opportunity) { FactoryGirl.create(:opportunity) }

      describe "GET index" do
        before(:each) { get :index }
        it { expect(response).to be_success }
        it { expect(assigns(:opportunities)).to eq([opportunity]) }
      end

      describe "GET show" do
        before(:each) { get :show, id: opportunity.id }
        it { expect(response).to be_success }
        it { expect(assigns(:opportunity)).to eq(opportunity) }
      end

      describe "GET edit" do
        before(:each) { get :edit, id: opportunity.id }
        it { expect(response).to be_success }
        it { expect(assigns(:opportunity)).to eq(opportunity) }
      end

      describe "DELETE destroy" do
        before(:each) { delete :destroy, id: opportunity.id }
        it { expect(Opportunity.count).to eq(0) }
        it { expect(response).to redirect_to(opportunities_url) }
      end

    end

    describe "GET new" do
      before(:each) { get :new }
      it { expect(response).to be_success }
      it { expect(assigns(:opportunity)).to be_a_new(Opportunity) }
    end

    describe "POST create" do
      before(:each) { post :create }
      it { expect(response).to redirect_to(Opportunity.last) }
      it { expect(Opportunity.count).to eq(1) }
      it { expect(assigns(:opportunity)).to be_a(Opportunity) }
      it { expect(assigns(:opportunity)).to be_persisted }
    end
  end
end
