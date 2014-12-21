require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class VerifyJobTest < Minitest::Test
  subject { VerifyJob.new :options => options }

  should_behave_like_a_transporter_job
  should_have_the_command_name("Verify")
  should_have_the_target_name("package.itmsp")
  should_have_the_target_name_when_stringified

  context "when saved" do
    context "the verify_assets option" do
      should "be converted to TrueClass" do
        subject.options[:verify_assets] = "true"
        subject.save!
        assert_instance_of TrueClass, subject.options[:verify_assets]
      end

      should "be converted to FalseClass" do
        subject.options[:verify_assets] = "false"
        subject.save!
        assert_instance_of FalseClass, subject.options[:verify_assets]
      end
    end
  end

  context "#perform" do
    setup do
      stub(@itms={}).verify
      stub(subject).itms { @itms }
      subject.perform
    end

    should "perform verification" do
      assert_received(@itms) { |itms| itms.verify(options[:package], is_a(Hash)) }
    end
  end

  protected
  def options
    { :package => "/a/package.itmsp" }
  end
end
