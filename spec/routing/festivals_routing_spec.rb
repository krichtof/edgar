require "rails_helper"

describe FestivalsController do
  describe "routing" do

    it "routes to #index" do
      get("/festivals").should route_to("festivals#index")
    end

    it "routes to #new" do
      get("/festivals/new").should route_to("festivals#new")
    end

    it "routes to #show" do
      get("/festivals/1").should route_to("festivals#show", :id => "1")
    end

    it "routes to #edit" do
      get("/festivals/1/edit").should route_to("festivals#edit", :id => "1")
    end

    it "routes to #create" do
      post("/festivals").should route_to("festivals#create")
    end

    it "routes to #update" do
      put("/festivals/1").should route_to("festivals#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/festivals/1").should route_to("festivals#destroy", :id => "1")
    end

  end
end
