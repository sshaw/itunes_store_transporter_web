require "spec_helper"

RSpec.describe SendNotificationJob, :jobs do
  before { @upload = create(:upload_job, :account => create(:account)) }

  describe "#queue_name" do
    it "returns 'notifications'" do
      expect(described_class.new(@upload.id).queue_name).to eq "notifications"
    end
  end

  describe "#perform" do
    it "calls SendNotification#send with the job's id" do
      sender = instance_double("SendNotification")
      expect(sender).to receive(:send).with(@upload.id)

      expect(SendNotification).to receive(:new).and_return(sender)

      job = described_class.new(@upload.id)
      job.perform
    end
  end
end
