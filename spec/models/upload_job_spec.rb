require "spec_helper"
require "shared_examples/a_transporter_job"

RSpec.describe UploadJob, :model do
  subject(:job) { build(:upload_job) }

  it_should_behave_like "a transporter job"

  # delayed_job hook
  describe "#after" do
    context "when the account has no notifications configured" do
      it "does not enqueue an email notification job" do
        job.account.notification = nil
        job.save!

        expect(Delayed::Job).to_not receive(:enqueue)

        job.after(double())
      end
    end

    context "when the account has a notification configured" do
      it "enqueues an email notification job" do
        job.account.notification = build(:notification)
        job.save!

        expect(Delayed::Job).to receive(:enqueue).with(SendNotificationJob.new(job.id))

        job.after(double())
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
