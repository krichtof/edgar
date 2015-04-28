require 'rails_helper'

describe VenuesController do

  context "with a logged user" do

    let(:user) { FactoryGirl.create(:admin, label_name: "truc") }

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end

    context "with an existing venue" do
      let!(:venue) { FactoryGirl.create(:venue) }

      describe "GET index" do
        before(:each) { get :index }
        it { expect(response).to be_success }
        it { expect(assigns(:contacts)).to eq([venue]) }
      end

      describe "GET show" do
        before(:each) { get :show, id: venue.id }
        it { expect(response).to be_success }
        it { expect(assigns(:venue)).to eq(venue) }
      end

      describe "GET edit" do
        before(:each) { get :edit, id: venue.id }
        it { expect(response).to be_success }
        it { expect(assigns(:venue)).to eq(venue) }
      end

      describe "PUT update" do
        before(:each) { post :update, id: venue.id }
        it { expect(assigns(:venue)).to eq(venue) }
        it { expect(response).to redirect_to(venue) }
      end

      describe "DELETE destroy" do
        before(:each) { delete :destroy, id: venue.id }
        it { expect(Venue.count).to eq(0) }
        it { expect(response).to redirect_to(venues_url) }
      end
    end

    describe "GET new" do
      before(:each) { get :new }
      it { expect(response).to be_success }
      it { expect(assigns(:venue)).to be_a_new(Venue) }
    end

    describe "POST create" do
      before(:each) { post :create, venue: {} }
      it { expect(Venue.count).to eq(1) }
      it { expect(assigns(:venue)).to be_a(Venue) }
      it { expect(assigns(:venue)).to be_persisted }
      it { expect(response).to redirect_to(edit_venue_path(Venue.last)) }
    end
  end
end
