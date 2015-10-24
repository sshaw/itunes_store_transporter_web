require "spec_helper"
require "shared_examples_for_a_transporter_job"

RSpec.describe VerifyJob, :model do
  subject(:job) { build(:verify_job, :options => { :package => "/a/package.itmsp" }) }

  it_should_behave_like "a transporter job"

  describe "when executed" do
    it "verifies the package" do
      itms = stub_itms(job)
      expect(itms).to receive(:verify).with(
                        job.options[:package],
                        hash_excluding(:package => job.options[:package])
                      ).and_return(true)

      job.perform

      expect(job.result).to eq true
    end
  end
end
