require "spec_helper"

Dir.glob(Padrino.root("app/mailers/*.rb")).each { |path| require path }

RSpec.describe "notification emails" do
  include Mail::Matchers

  before do
    Mail::TestMailer.deliveries.clear

    notice = build(:notification,
                   :subject => "Hi <%= job_id %>",
                   :reply_to => "reply@example.com",
                   :from => "from@example.com",
                   :to => "t1@example.com,t2@example.com",
                   :message => "Bye <%= job_id %>")

    account = create(:account, :notification => notice)
    @job = create(:upload_job, :account => account)
  end

  # TODO: test it was sent using via
  describe "job_completed" do
    before { app.deliver(:notifications, :job_completed, @job) }

    it { is_expected.to have_sent_email.from("from@example.com") }
    it { is_expected.to have_sent_email.to(%w[t1@example.com t2@example.com]) }
    it { is_expected.to have_sent_email.to(%w[t1@example.com t2@example.com]) }
    it { is_expected.to have_sent_email.with_subject("Hi #{@job.id}") }
    it { is_expected.to have_sent_email.with_body("Bye #{@job.id}") }

    it "uses the configured reply_to email" do
      expect(Mail::TestMailer.deliveries.first.reply_to).to eq %w[reply@example.com]
    end
  end
end
