require "rails_helper"

describe UserMailer do
  before(:all) do
    @user = FactoryGirl.create(:user, label_name: "mondial")
    @email = UserMailer.welcome_email(@user)
  end

  it "should be delivered to the email address provided" do
    expect(@email.to).to eq([@user.email])
  end

  it "should contain the correct message in the mail body" do
    expect(@email.body.encoded).to match('Welcome')
  end

  it "should have the correct subject" do
    expect(@email.subject).to match('Request Received')
  end

end
