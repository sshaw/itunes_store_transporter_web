require "spec_helper"
require "shared_examples/a_transporter_job"

RSpec.describe UploadJob, :model do
  subject(:job) { build(:upload_job) }

  it_should_behave_like "a transporter job"

  describe "#after" do
    context "given a program to execute" do
      it "enqueues a RunExecuteHookJob" do
        job = create(:upload_job, :execute => "foo")
        expect(Delayed::Job).to receive(:enqueue).with(RunExecuteHookJob.new(job.id))

        job.after(double("Job"))
      end
    end

    context "given no program to execute" do
      it "does not enqueue a RunExecuteHookJob" do
        job = create(:upload_job, :execute => nil)
        expect(Delayed::Job).to_not receive(:enqueue)

        job.after(double("Job"))
      end
    end
  end

  # describe "when executed" do
  #   it "retrieves metadata for the given identifier" do
  #     status = {:x => 123}

  #     itms = stub_itms(job)
  #     expect(itms).to receive(:status).with(hash_including(job.options)).and_return(status)

  #     job.perform

  #     expect(job.result).to eq status
  #   end
  # end
end
