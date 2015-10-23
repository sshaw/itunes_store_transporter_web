require "spec_helper"
require "shared_examples_for_a_transporter_job"

RSpec.describe UploadJob, :model do
  subject(:job) { build(:upload_job) }

  it_should_behave_like "a transporter job"

  # describe "#perform" do
  #   it "retrieves metadata for the given identifier" do
  #     status = {:x => 123}

  #     itms = stub_itms(job)
  #     expect(itms).to receive(:status).with(hash_including(job.options)).and_return(status)

  #     job.perform

  #     expect(job.result).to eq status
  #   end
  # end
end
