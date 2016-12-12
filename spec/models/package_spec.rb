require "spec_helper"

RSpec.describe Package do
  subject(:package) { build(:package) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:vendor_id) }
  it { is_expected.to validate_uniqueness_of(:vendor_id) }
  it { is_expected.to validate_presence_of(:account_id) }

  context "when a completed upload job exists" do
    it "sets current_status to the job's state" do
      job = create(:upload_job)
      job.failure!

      pkg = create(:package, :vendor_id => job.target)
      expect(pkg.current_status).to eq "Failure"
    end
  end

  describe "status history" do
    context "when current_status changes from a non-nil value" do
      it "adds its old status to status_history" do
        pkg = create(:package, :current_status => "Bar")
        pkg.update!(:current_status => "Foo")

        expect(pkg.status_history.size).to eq 1
        expect(pkg.status_history.first.name).to eq "Bar"
      end
    end
  end
end
