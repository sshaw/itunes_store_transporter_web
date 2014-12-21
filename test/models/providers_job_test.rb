require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class ProvidersJobTest < Minitest::Test
  should_behave_like_a_transporter_job
  should_have_the_target_name(nil)
  should_have_the_command_name("Providers")

  context "#perform" do
    setup do
      stub(@itms={}).providers
      stub(subject).itms { @itms }
      subject.perform
    end

    should "retrieve the providers" do
      assert_received(@itms) { |itms| itms.providers(is_a(Hash)) }
    end
  end
end
