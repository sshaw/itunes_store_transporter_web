require "spec_helper"

RSpec.describe ITunes::Store::Transporter::Web::Command do
  before do
    options = {
      :package => "/a/package.itmsp",
      :shortname => "sshaw",
      :username => "SomeUsername"
    }

    @job = create(:upload_job, :options => options)
    @command = described_class.new(@job)
  end

  describe "#execute" do
    it "runs the command and returns its stdout" do
      expect(@command.execute(ruby("print 123"))).to eq "123"
    end

    it "runs the command and returns its stderr" do
      expect(@command.execute(ruby("$stderr.print 123"))).to eq "123"
    end

    it "sets the ITMS_JOB_ID environment variable" do
      expect(@command.execute(env("ITMS_JOB_ID"))).to eq @job.id.to_s
      expect(ENV["ITMS_JOB_ID"]).to be_nil
    end

    it "sets the ITMS_JOB_PACKAGE_PATH environment variable" do
      expect(@command.execute(env("ITMS_JOB_PACKAGE_PATH"))).to eq "/a/package.itmsp"
      expect(ENV["ITMS_JOB_PACKAGE_PATH"]).to be_nil
    end

    it "sets the ITMS_JOB_STATE environment variable" do
      expect(@command.execute(env("ITMS_JOB_STATE"))).to eq "queued"
      expect(ENV["ITMS_JOB_STATE"]).to be_nil
    end

    it "sets the ITMS_JOB_TYPE environment variable" do
      expect(@command.execute(env("ITMS_JOB_TYPE"))).to eq "upload"
      expect(ENV["ITMS_JOB_TYPE"]).to be_nil
    end

    it "sets the ITMS_JOB_TARGET environment variable" do
      expect(@command.execute(env("ITMS_JOB_TARGET"))).to eq "package.itmsp"
      expect(ENV["ITMS_JOB_TARGET"]).to be_nil
    end

    it "sets the ITMS_JOB_CREATED environment variable" do
      expect(@command.execute(env("ITMS_JOB_CREATED"))).to eq @job.created_at.to_s
      expect(ENV["ITMS_JOB_CREATED"]).to be_nil
    end

    it "sets the ITMS_JOB_COMPLETED environment variable" do
      expect(@command.execute(env("ITMS_JOB_COMPLETED"))).to eq @job.updated_at.to_s
      expect(ENV["ITMS_JOB_COMPLETED"]).to be_nil
    end

    it "sets the ITMS_ACCOUNT_USERNAME environment variable" do
      expect(@command.execute(env("ITMS_ACCOUNT_USERNAME"))).to eq "SomeUsername"
      expect(ENV["ITMS_ACCOUNT_USERNAME"]).to be_nil
    end

    it "sets the ITMS_ACCOUNT_SHORTNAME environment variable" do
      expect(@command.execute(env("ITMS_ACCOUNT_SHORTNAME"))).to eq "sshaw"
      expect(ENV["ITMS_ACCOUNT_SHORTNAME"]).to be_nil
    end

    context "when the command exits non-zero" do
      it "raises an ExecutionError" do
        expect { @command.execute(ruby("$stderr.print 'foo'; exit 1")) }.to raise_error(described_class::NonZeroExitError, /foo/)
      end
    end

    context "when the command cannot be found" do
      it "raises an ExecutionError" do
        expect { @command.execute("__foo__") }.to raise_error(described_class::NonZeroExitError, /__foo__/)
      end
    end

    context "when the command is not executable" do
      before { @file = Tempfile.new("itms") }

      after do
        @file.close
        @file.unlink
      end

      it "raises an ExecutionError" do
        expect { @command.execute(@file.path) }.to raise_error(described_class::NonZeroExitError, /#{@file.path}/)
      end
    end
  end

  def env(var)
    ruby(%(print ENV["#{var}"]))
  end

  def ruby(code)
    "ruby -e'#{code}'"
  end
end
