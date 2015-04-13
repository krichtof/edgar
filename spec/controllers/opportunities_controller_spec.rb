require 'rails_helper'

describe OpportunitiesController do

  let(:valid_attributes) { {  } }

  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all opportunities as @opportunities" do
      opportunity = Opportunity.create! valid_attributes
      get :index, {}, valid_session
      assigns(:opportunities).should eq([opportunity])
    end
  end

  describe "GET show" do
    it "assigns the requested opportunity as @opportunity" do
      opportunity = Opportunity.create! valid_attributes
      get :show, {:id => opportunity.to_param}, valid_session
      assigns(:opportunity).should eq(opportunity)
    end
  end

  describe "GET new" do
    it "assigns a new opportunity as @opportunity" do
      get :new, {}, valid_session
      assigns(:opportunity).should be_a_new(Opportunity)
    end
  end

  describe "GET edit" do
    it "assigns the requested opportunity as @opportunity" do
      opportunity = Opportunity.create! valid_attributes
      get :edit, {:id => opportunity.to_param}, valid_session
      assigns(:opportunity).should eq(opportunity)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Opportunity" do
        expect {
          post :create, {:opportunity => valid_attributes}, valid_session
        }.to change(Opportunity, :count).by(1)
      end

      it "assigns a newly created opportunity as @opportunity" do
        post :create, {:opportunity => valid_attributes}, valid_session
        assigns(:opportunity).should be_a(Opportunity)
        assigns(:opportunity).should be_persisted
      end

      it "redirects to the created opportunity" do
        post :create, {:opportunity => valid_attributes}, valid_session
        response.should redirect_to(Opportunity.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved opportunity as @opportunity" do
        # Trigger the behavior that occurs when invalid params are submitted
        Opportunity.any_instance.stub(:save).and_return(false)
        post :create, {:opportunity => {  }}, valid_session
        assigns(:opportunity).should be_a_new(Opportunity)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Opportunity.any_instance.stub(:save).and_return(false)
        post :create, {:opportunity => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested opportunity" do
        opportunity = Opportunity.create! valid_attributes
        # Assuming there are no other opportunities in the database, this
        # specifies that the Opportunity created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Opportunity.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:id => opportunity.to_param, :opportunity => { "these" => "params" }}, valid_session
      end

      it "assigns the requested opportunity as @opportunity" do
        opportunity = Opportunity.create! valid_attributes
        put :update, {:id => opportunity.to_param, :opportunity => valid_attributes}, valid_session
        assigns(:opportunity).should eq(opportunity)
      end

      it "redirects to the opportunity" do
        opportunity = Opportunity.create! valid_attributes
        put :update, {:id => opportunity.to_param, :opportunity => valid_attributes}, valid_session
        response.should redirect_to(opportunity)
      end
    end

    describe "with invalid params" do
      it "assigns the opportunity as @opportunity" do
        opportunity = Opportunity.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Opportunity.any_instance.stub(:save).and_return(false)
        put :update, {:id => opportunity.to_param, :opportunity => {  }}, valid_session
        assigns(:opportunity).should eq(opportunity)
      end

      it "re-renders the 'edit' template" do
        opportunity = Opportunity.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Opportunity.any_instance.stub(:save).and_return(false)
        put :update, {:id => opportunity.to_param, :opportunity => {  }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested opportunity" do
      opportunity = Opportunity.create! valid_attributes
      expect {
        delete :destroy, {:id => opportunity.to_param}, valid_session
      }.to change(Opportunity, :count).by(-1)
    end

    it "redirects to the opportunities list" do
      opportunity = Opportunity.create! valid_attributes
      delete :destroy, {:id => opportunity.to_param}, valid_session
      response.should redirect_to(opportunities_url)
    end
  end

end
