require "spec_helper"
require "shared_examples_for_a_transporter_job"

RSpec.describe ProvidersJob, :model do
  subject(:job) { build(:providers_job) }

  it_should_behave_like "a transporter job"

  describe "when executed" do
    it "retrieves a list of providers" do
      providers = [1,2,3]

      itms = stub_itms(job)
      expect(itms).to receive(:providers).with(hash_including(job.options)).and_return(providers)

      job.perform

      expect(job.result).to eq providers
    end
  end
end
