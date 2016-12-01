FactoryGirl.define do
  factory :account do
    sequence(:username) { |n| "user#{n}" }
    sequence(:shortname) { |n| "short#{n}" }
    sequence(:alias) { |n| "alias#{n}" }
    password "p@ss!@#"
  end
end
