require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class UploadJobTest < Minitest::Test
  subject { UploadJob.new :options => options }

  should_behave_like_a_transporter_job
  should_have_the_command_name("Upload")
  should_have_the_target_name("package.itmsp")
  should_have_the_target_name_when_stringified

  context "when saved" do
    context "the delete option" do
      should "be converted to TrueClass" do
        subject.options[:delete] = "true"
        subject.save!
        assert_instance_of TrueClass, subject.options[:delete]
      end

      should "be converted to FalseClass" do
        subject.options[:delete] = "false"
        subject.save!
        assert_instance_of FalseClass, subject.options[:delete]
      end
    end

    context "the rate option" do
      should "be converted to a Fixnum" do
        subject.options[:rate] = "1"
        subject.save!
        assert_equal 1, subject.options[:rate]
      end

      should "not be converted to a Fixnum" do
        subject.options[:rate] = "A"
        subject.save!
        assert_equal "A", subject.options[:rate]
      end
    end
  end

  context "#perform" do
    setup do
      stub(@itms={}).upload
      stub(subject).itms { @itms }
      subject.perform
    end

    should "perform the upload" do
      assert_received(@itms) { |itms| itms.upload(options[:package], hash_including(options.except(:package))) }
    end
  end

  protected
  def options
    { :package => "/a/package.itmsp", :username => "sshaw" }
  end
end
