require 'rails_helper'

describe BackdoorController do

  describe "GET 'play1'" do
    it "returns http success" do
      get 'play1'
      expect(response).to be_redirect
      expect(response).to redirect_to(new_user_session_path(locale: nil))
    end
  end

end
