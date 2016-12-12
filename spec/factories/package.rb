FactoryGirl.define do
  factory :package do
    account
    sequence(:title) { |n| "Title #{n}" }
    sequence(:vendor_id) { |n| "Vendor ID #{n}" }
  end
end
