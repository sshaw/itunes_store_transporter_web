require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class LookupJobTest < Minitest::Test
  should_behave_like_a_transporter_job
  should_have_the_command_name("Lookup")

  context "using a vendor id" do
    subject { LookupJob.create! :options => options }
    should_have_the_target_name("VID")
    should_have_the_target_name_when_stringified
  end

  context "using an apple id" do
    subject { LookupJob.create! :options => { :apple_id => "AID" } }
    should_have_the_target_name("AID")
    should_have_the_target_name_when_stringified
  end

  context "#perform" do
    setup do
      stub(@itms={}).lookup
      stub(subject).itms { @itms }
      subject.options = options
      subject.perform
    end

    should "lookup the metadata" do
      assert_received(@itms) { |itms| itms.lookup(hash_including(options)) }
    end
  end

  protected
  def options
    { :vendor_id => "VID" }
  end
end
