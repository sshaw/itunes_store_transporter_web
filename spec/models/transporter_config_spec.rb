require "spec_helper"

require "options"
require "itunes/store/transporter/shell"

RSpec.describe TransporterConfig, :model do
  subject(:config) { build(:transporter_config) }

  it { should validate_numericality_of(:rate) }
  it { should_not allow_value(0).for(:rate) }
  it { should_not allow_value(-1).for(:rate) }

  Options::TRANSPORTS.each do |opt|
    it { should allow_value(opt).for(:transport) }
  end

  describe "#path" do
    it "defaults to the system Transporter path" do
      expect(config.path).to eq ITunes::Store::Transporter::Shell.default_path
    end

    it "can be overridden" do
      config.update_attributes!(:path => "foo")
      expect(config.path).to eq "foo"
    end
  end
end
