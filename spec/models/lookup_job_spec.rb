require "spec_helper"
require "shared_examples_for_a_transporter_job"

RSpec.describe LookupJob, :model do
  subject(:job) { build(:lookup_job) }

  it_should_behave_like "a transporter job"

  describe "#perform" do
    it "retrieves metadata for the given identifier" do
      metadata = "<x>123</x>"

      itms = stub_itms(job)
      expect(itms).to receive(:lookup).with(hash_including(job.options)).and_return(metadata)

      job.perform

      expect(job.result).to eq metadata
    end
  end
end
