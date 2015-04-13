# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email}
    password 'changeme'
    password_confirmation 'changeme'
    confirmed_at Time.now

    after(:build) do |user|
      account = FactoryGirl.build(:account)
      user.accounts = [account]
      FactoryGirl.build(:abilitation, user: user, account: account)
      user.add_role(:member)
    end

  end

  factory :admin, parent: :user do
    after(:build) do |user|
      user.add_role(:admin)
    end
  end
end
