require "tempfile"

shared_examples_for "a transporter job" do
  it { should belong_to(:account) }
  it { should validate_presence_of(:account_id) }
  it { should_not allow_mass_assignment_of(:state) }
  it { should_not allow_mass_assignment_of(:target) }
  it { should_not allow_mass_assignment_of(:job_id) }

  described_class::STATES.each do |state|
    describe "##{state}!" do
      it "sets the state to #{state}" do
        job.save!
        job.public_send("#{state}!")

        expect(job.state).to eq state
        expect(job.public_send("#{state}?")).to be true
      end
    end
  end

  describe "#to_s" do
    it "contains the job type" do
      expect(job.to_s).to match(/\b#{job.type}\sJob\b/)
    end
  end

  describe "#output" do
    before do
      @output = "ABC"
      @log = Tempfile.new("itms")
      File.open(@log, "w") { |io| io.write(@output) }

      allow(job).to receive(:log).and_return(@log.path)
    end

    after { @log.delete }

    context "with no offset" do
      it "returns all the log data" do
        expect(job.output).to eq @output
      end
    end

    context "with a valid offset" do
      it "returns the log data at the given offset" do
        expect(job.output(1)).to eq @output[1..-1]
      end
    end
  end

  describe "when created" do
    before { job.save! }

    it "is added to the processing queue" do
      expect(Delayed::Job.exists?(subject.job_id)).to be true
    end

    it "sets the state to queued" do
      expect(job).to be_queued
    end

    it "sets the priority to :normal" do
      expect(job.priority).to be :normal
    end

    describe "#completed?" do
      it "returns false" do
        expect(job).to_not be_completed
      end
    end
  end

  describe "when executed" do
    before do
      Delayed::Worker.delay_jobs = false
      stub_itms(job).as_null_object
    end

    after do
      Delayed::Worker.delay_jobs = true
    end

    it "sets the state to running" do
      expect(job).to receive(:running!).once
      job.save!
    end

    it "adds the job's log file to the its options" do
      allow(job).to receive(:run) do
        expect(job.options[:log]).to match /#{job.id}.log\Z/
      end

      job.save!

      expect(job.options).to_not include(:log)
    end

    context "when successful" do
      before { job.save! }

      it "sets the state to success" do
        expect(job).to be_success
      end

      describe "#completed?" do
        it "returns true" do
          expect(job).to be_completed
        end
      end
    end

    context "when an exception occurs" do
      before do
        @error = StandardError.new("bad thangz going down")
        allow(job).to receive(:run).and_raise(@error)

        begin
          job.save!
        rescue => e
        end
      end

      it "sets the state to failure" do
        expect(job).to be_failure
      end

      it "saves the exception" do
        expect(job.exceptions).to be_a @error.class
        expect(job.exceptions.message).to eq @error.message
      end

      describe "#completed?" do
        it "returns true" do
          expect(job).to be_completed
        end
      end
    end
  end
end
