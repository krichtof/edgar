FactoryGirl.define do
  factory :abilitation do
    user
    account

    trait :member do
      kind 'member'
    end

    trait :admin do
      kind 'admin'
    end
  end
end
