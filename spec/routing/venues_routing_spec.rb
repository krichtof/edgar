require "rails_helper"

describe VenuesController do
  describe "routing" do

    it "routes to #index" do
      get("/venues").should route_to("venues#index")
    end

    it "routes to #new" do
      get("/venues/new").should route_to("venues#new")
    end

    it "routes to #show" do
      get("/venues/1").should route_to("venues#show", :id => "1")
    end

    it "routes to #edit" do
      get("/venues/1/edit").should route_to("venues#edit", :id => "1")
    end

    it "routes to #create" do
      post("/venues").should route_to("venues#create")
    end

    it "routes to #update" do
      put("/venues/1").should route_to("venues#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/venues/1").should route_to("venues#destroy", :id => "1")
    end

  end
end
