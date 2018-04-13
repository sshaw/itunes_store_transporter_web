FactoryGirl.define do
  factory :account do
    sequence(:username) { |n| "user#{n}" }
    sequence(:shortname) { |n| "short#{n}" }
    sequence(:itc_provider) { |n| "provider#{n}" }
    password "p@ss!@#"
  end
end
