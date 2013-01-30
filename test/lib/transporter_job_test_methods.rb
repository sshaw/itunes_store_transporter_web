require "active_support/concern"

module TransporterJobTestMethods
  extend ActiveSupport::Concern

  included do
    # We prefer this function to Delayed::Worker.delay_jobs = false.
    # Otherwise, since job.save adds the job to the queue, we would need to stub/mock run() for every
    # test case to avoid really running to job
    def runjob(klass, optionz = {}, &block)
      optionz[:result] ||= "data"

      job = klass.new
      job.options = optionz[:options] if optionz[:options]
      job.save!

      any_instance_of(klass) do |j|
        stub(j).run { block_given? ? block.call : optionz[:result] }
      end

      Delayed::Worker.new.work_off(1)

      job.reload
      job
    end

    def priority(id)
      Delayed::Job.find(id).priority
    end
  end

  module ClassMethods
    def should_have_the_command_name(name)
      context "#command" do
        should "be named #{name}" do
          assert_equal name, subject.command
        end
      end
    end

    def should_have_the_target_name(name)
      context "#target" do
        should "be named #{name}" do
          assert_equal name, subject.target
        end
      end
    end

    def should_have_the_target_name_when_stringified
      context "#to_s" do
        should "contain target name" do
          assert subject.to_s =~ /\b#{subject.target}\b/
        end
      end
    end

    def should_behave_like_a_transporter_job
      context "a job" do
        teardown do
          TransporterJob.destroy_all
          Delayed::Job.destroy_all
        end

        should_not allow_mass_assignment_of :state
        should_not allow_mass_assignment_of :job_id

        should "be a TransporterJob" do
          assert subject.is_a? TransporterJob
        end

        described_type::STATES.each do |st|
          context "#{st}!" do
            setup do
              subject.save!
              subject.send("#{st}!")
            end

            should "set the state to #{st}" do
              assert_equal st, subject.state
              assert subject.send("#{st}?"), "#{st}?"
            end
          end
        end

        context "#to_s" do
          should "contain the job type" do
            assert subject.to_s =~ /\b#{subject.type}\sJob\b/
          end
        end


        context "#output" do
          setup do
            @output = "ABC"
            subject.save!
            File.open(subject.send(:log), "w") { |io| io.write(@output) }
          end

          context "with no offset" do
            should "return all the data" do
              assert_equal @output, subject.output
            end
          end

          context "with a valid offset" do
            should "return the data at the given offset" do
              assert_equal @output[1..-1], subject.output(1)
            end
          end
        end

        # If we're already saved we can't update job priority!
        # just use has_one and proxy to job.priority
        context "job priority" do
          context ":low" do
            setup do
              subject.priority = :low
              subject.save!
            end

            should "create a job queue priority of 1" do
              assert_equal 1, priority(subject.job_id)
            end
          end

          context ":normal" do
            setup do
              subject.priority = :normal
              subject.save!
            end

            should "create a job queue priority of 0" do
              assert_equal 0, priority(subject.job_id)
            end
          end

          context ":high" do
            setup do
              subject.priority = :high
              subject.save!
            end

            should "create a job queue priority of -1" do
              assert_equal -1, priority(subject.job_id)
            end
          end

          context ":next" do
            setup do
              subject.priority = :next
              subject.save!
              @higher = self.class.described_type.create!(:options  => subject.options,
                                                          :priority => :next)
            end

            should "create a job with the highest priority" do
              assert_equal -1, priority(subject.job_id)
              assert_equal -2, priority(@higher.job_id)
            end
          end
        end

        context "when created" do
          setup do
            @options = { :username => "sshaw", :vendor_id => "123123" }
            subject.options = @options
            subject.save!
          end

          # when no configured location...
          should "create a log filename under the configured location" do
            log = subject.send(:log)
            config = AppConfig.first_or_initialize
            assert log.present?, "logname created"
            assert log.start_with?(config.output_log_directory), "starts with '#{config.output_log_directory}'"
          end

          should "be in the queued state" do
            assert_equal :queued, subject.state
          end

          should "be in the job queue" do
            assert Delayed::Job.exists?(subject.job_id)
          end

          should "save the options" do
            assert_equal @options, subject.options
          end

          should "have a priority of :normal" do
            assert_equal :normal, subject.priority
          end
        end

        context "when ran" do
          setup do
            # This smells odd...
            @options = {}
            stub(@options).[]=
            stub(@options).delete

            stub(subject).options { @options }
            stub(subject).running!
            stub(subject).run

            subject.perform
          end

          should "have been in the running state" do
            assert_received(subject) { |job| job.running! }
          end

          # stderr/out
          context "the command's options" do
            # How do we know what happened first?!
            should "have contained the job's log file" do
              assert_received(@options) { |opt| opt.[]=(:log, is_a(String)) }
            end

            should "no longer contain the job's log file" do
              assert_received(@options) { |opt| opt.delete(:log) }
            end
          end
        end

        context "when successful" do
          subject { runjob(self.class.described_type) }

          should "be in the success state" do
            assert_equal :success, subject.state
          end

          context "when the result is a Hash" do
            setup do
              @result = { :a => 123 }
              @job = runjob(self.class.described_type, :result => @result)
            end

            should "be saved" do
              assert_equal @result, @job.result
            end
          end

          context "when the result is a Array" do
            setup do
              @result = [1, 2]
              @job = runjob(self.class.described_type, :result => @result)
            end

            should "be saved" do
              assert_equal @result, @job.result
            end
          end

          context "when the result is a String" do
            setup do
              @result = "<x>123</x>"
              @job = runjob(self.class.described_type, :result => @result)
            end

            should "be saved" do
              assert_equal @result, @job.result
            end
          end
        end

        context "when deleted" do
          setup do
            @job = self.class.described_type.create!
            @log = @job.send(:log)
            File.open(@log, "w") { |io| io.write("data") }
            @job.destroy
          end

          should "be removed from the job queue" do
            assert !Delayed::Job.exists?(@job.job_id)
          end

          should "delete the job's log file" do
            assert !File.exists?(@log)
          end
        end

        context "when an exception is raised" do
          subject do
            runjob self.class.described_type do
              msg   = ITunes::Store::Transporter::TransporterMessage.new("some error", 9999)
              error = ITunes::Store::Transporter::ExecutionError.new(msg, 1)
              raise error
            end
          end

          should "be in the failure state" do
            assert_equal :failure, subject.state
          end

          should "save the exceptions" do
            # OptionError, TransporterError
            ex = subject.exceptions
            assert_kind_of ITunes::Store::Transporter::ExecutionError, ex
            assert_equal 1, ex.exitstatus
            assert_equal 1, ex.errors.size

            msg = ex.errors[0]
            assert_kind_of ITunes::Store::Transporter::TransporterMessage, msg
            assert_equal 9999, msg.code
            assert_equal "some error", msg.message
          end
        end
      end
    end
  end
end
