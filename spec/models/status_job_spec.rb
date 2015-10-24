require "spec_helper"
require "shared_examples_for_a_transporter_job"

RSpec.describe StatusJob, :model do
  subject(:job) { build(:status_job) }

  it_should_behave_like "a transporter job"

  describe "when executed" do
    it "retrieves metadata for the given identifier" do
      status = {:x => 123}

      itms = stub_itms(job)
      expect(itms).to receive(:status).with(hash_including(job.options)).and_return(status)

      job.perform

      expect(job.result).to eq status
    end
  end
end
