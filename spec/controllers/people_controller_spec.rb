require 'rails_helper'

describe PeopleController do

  context "with a logged user" do

    let(:user) { FactoryGirl.create(:admin, label_name: "truc") }

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end

    context "with an existing person" do
      let!(:person) { FactoryGirl.create(:person) }

      describe "GET index" do
        before(:each) { get :index }
        it { expect(response).to be_success }
      end

      describe "GET show" do
        before(:each) { get :show, id: person.id }
        it { expect(response).to be_success }
        it { expect(assigns(:person)).to eq(person) }
      end

      describe "GET edit" do
        before(:each) { get :edit, id: person.id }
        it { expect(response).to be_success }
        it { expect(assigns(:person)).to eq(person) }
      end

      describe "PUT update" do
        before(:each) { post :update, id: person.id, person: { first_name: "Raymond The King" } }
        it { expect(response).to redirect_to(person.reload) }
        it { expect(person.reload.first_name).to eq("Raymond The King") }
      end


      describe "DELETE destroy" do
        before(:each) {delete :destroy, id: person.id }
        it { expect(response).to redirect_to(people_url) }
        it { expect(Person.count).to eq(0) }
      end
    end

    describe "GET new" do
      before(:each) { get :new }
      it { expect(response).to be_success }
      it { expect(assigns(:person)).to be_a_new(Person) }
    end

    describe "POST create" do
      before(:each) { post :create, person: {first_name: "truc", last_name: "bidule"} }
      it { expect(response).to redirect_to(Person.first) }
      it { expect(Person.count).to eq(1) }
      it { expect(assigns(:person)).to be_a(Person) }
    end
  end
end
