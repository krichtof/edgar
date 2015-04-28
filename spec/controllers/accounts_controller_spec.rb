require 'rails_helper'

describe AccountsController do

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      expect(response).to be_redirect
      expect(response).to redirect_to(new_user_session_path(locale: nil))
    end
  end

  describe "GET 'update'" do
    it "returns http success" do
      get 'update'
      expect(response).to be_redirect
      expect(response).to redirect_to(new_user_session_path(locale: nil))
    end
  end

end
