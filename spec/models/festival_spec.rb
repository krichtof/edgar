require "rails_helper"

describe Festival do

  it { expect(FactoryGirl.build(:festival)).to be_valid }
end
