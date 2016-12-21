require "spec_helper"

RSpec.describe Status do
  it { is_expected.to validate_presence_of(:time) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:package) }
end
