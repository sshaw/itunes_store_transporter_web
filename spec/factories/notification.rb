FactoryGirl.define do
  factory :notification do
    sequence(:name) { |i| "Notification #{i}" }
    to "screenstaring@example.com"
    from "sshaw@example.com"
    subject "Good thangz"
    message "Hi!"
  end
end
