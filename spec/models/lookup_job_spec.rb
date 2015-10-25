require "spec_helper"
require "shared_examples_for_a_transporter_job"

RSpec.describe LookupJob, :model do
  subject(:job) { build(:lookup_job) }

  it_should_behave_like "a transporter job"

  describe "#target" do
    it "uses the vendor id" do
      job.options = { :vendor_id => "VID" }
      expect(job.target).to eq job.options[:vendor_id]
    end

    it "uses the apple id" do
      job.options = { :apple_id => "AID" }
      expect(job.target).to eq job.options[:apple_id]
    end
  end

  describe "when executed" do
    it "retrieves metadata for the given identifier" do
      metadata = "<x>123</x>"

      itms = stub_itms(job)
      expect(itms).to receive(:lookup).with(hash_including(job.options)).and_return(metadata)

      job.perform

      expect(job.result).to eq metadata
    end
  end
end
