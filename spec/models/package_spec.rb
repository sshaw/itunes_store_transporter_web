require "spec_helper"
require "itunes/store/transporter/web/package_status"

include ITunes::Store::Transporter::Web

RSpec.describe Package do
  subject(:package) { build(:package) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:vendor_id) }
  it { is_expected.to validate_uniqueness_of(:vendor_id) }
  it { is_expected.to validate_presence_of(:account_id) }

  describe ".pending_uploads" do
    before do
      # This should never be returned
      create(:package, :current_status => PackageStatus::ON_STORE, :last_status_check => Time.current)
    end

    [PackageStatus::APPROVED, PackageStatus::IN_REVIEW, PackageStatus::REVIEW,
     PackageStatus::NOT_ON_STORE, PackageStatus::READY, "Uploaded", nil].each do |status|
      it "returns packages with a current_status of '#{status}'" do
        pkg = create(:package, :current_status => status)
        expect(described_class.pending_uploads).to eq [pkg]
      end
    end

    context "given a package with a status of '#{PackageStatus::ON_STORE}'" do
      context "that has not been uploaded withing 24 hours and has a last_status_check" do
        it "is not returned" do
          create(:package,
                 :current_status => PackageStatus::ON_STORE,
                 :last_status_check => 9.days.ago,
                 :last_upload => 10.days.ago)
          expect(described_class.pending_uploads).to be_empty
        end
      end

      context "that has been uploaded within 24 hours and has a last_status_check older than 24 hours" do
        it "is returned" do
          pkg = create(:package,
                       :current_status => PackageStatus::ON_STORE,
                       :last_status_check => 5.days.ago,
                       :last_upload => 23.hours.ago)
          expect(described_class.pending_uploads).to eq [pkg]
        end
      end

      context "that has no last_status_check time" do
        it "is returned" do
          pkg = create(:package, :current_status => PackageStatus::ON_STORE, :last_status_check => nil)
          expect(described_class.pending_uploads).to eq [pkg]
        end
      end
    end
  end

  context "when a completed upload job exists" do
    it "sets current_status to the job's state" do
      job = create(:upload_job)
      job.failure!

      pkg = create(:package, :vendor_id => job.target)
      expect(pkg.current_status).to eq "Failure"
    end
  end

  describe "status history" do
    context "when current_status changes from nil" do
      it "does not add the new status to status_history" do
        pkg = create(:package, :current_status => nil)
        expect(pkg.status_history.size).to eq 0

        pkg.update!(:current_status => "Foo")
        expect(pkg.status_history.size).to eq 0
      end
    end

    context "when current_status changes from non-nil" do
      it "adds its old status to status_history" do
        pkg = create(:package, :current_status => "Bar")
        pkg.update!(:current_status => "Foo")

        expect(pkg.status_history.size).to eq 1
        expect(pkg.status_history.first.name).to eq "Bar"
      end
    end

    context "when last_status_check changes from non-nil but status remains the same" do
      it "adds the status to status_history" do
        pkg = create(:package, :current_status => "Foo", :last_status_check => Time.current)
        pkg.update!(:last_status_check => Time.current)

        expect(pkg.current_status).to eq "Foo"
        expect(pkg.status_history.size).to eq 1
        expect(pkg.status_history.first.name).to eq "Foo"
      end
    end
  end
end
