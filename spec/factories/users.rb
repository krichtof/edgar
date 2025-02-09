
FactoryGirl.define do
  factory :user do
    label_name 'coucou'
    transient do
      manager true
      account { FactoryGirl.create(:account) }
    end

    email { Faker::Internet.email}
    password 'changeme'
    password_confirmation 'changeme'
    confirmed_at Time.now

    after(:build) do |user, evaluator|
      if evaluator.manager
        kind = 'manager'
      else
        kind = 'member'
      end

      abilitation = user.abilitations.build(kind: kind)
      abilitation.account = evaluator.account
      user.add_role(:member)
    end

  end

  factory :member, parent: :user do
     transient do
       manager false
     end
  end

  factory :admin, parent: :user do
    after(:build) do |user|
      user.add_role(:admin)
    end
  end
end
