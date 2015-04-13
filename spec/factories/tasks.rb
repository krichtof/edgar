# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :task do
    user
    name { Faker::Lorem.sentence[0,64] }
    category { %w(call email follow_up lunch meeting money presentation trip).sample }
    bucket "due_asap"
    due_at { FactoryGirl.generate(:time) }
  end

  factory :completed_task, :parent => :task do
    completed_at { Date.yesterday }
  end

  sequence :time do |n|
    Time.now - n.hours
  end

end
