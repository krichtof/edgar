require 'rails_helper'

describe "Festivals" do
  describe "GET /festivals" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get festivals_path
      response.status.should be(200)
    end
  end
end
