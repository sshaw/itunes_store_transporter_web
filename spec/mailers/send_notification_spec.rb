require "spec_helper"

Dir.glob(Padrino.root("app/mailers/*.rb")).each { |path| require path }

RSpec.describe SendNotification do
  before do
    Mail::TestMailer.deliveries.clear

    @account = create(:account, :notification => build(:notification))
    @job = create(:upload_job, :account => @account)
  end

  describe "#send" do
    it "sends a job_completed email" do
      described_class.new.send(@job.id)
      expect(Mail::TestMailer.deliveries.size).to eq 1
    end

    context "given a job without an account notification" do
      it "raises an ArgumentError" do
        expect {
          @account.notification = nil
          described_class.new.send(@job.id)
        }.to raise_error(ArgumentError, /account does not have a notification/)

        expect(Mail::TestMailer.deliveries).to be_empty
      end
    end
  end
end
