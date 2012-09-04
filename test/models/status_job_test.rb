require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class StatusJobTest < Test::Unit::TestCase  
  subject { StatusJob.new :options => options }

  should_behave_like_a_transporter_job
  should_have_the_command_name("Status")
  should_have_the_target_name("VID")
  should_have_the_target_name_when_stringified

  context "#perform" do
    setup do 
      stub(@itms={}).status
      stub(subject).itms { @itms }
      subject.perform
    end

    should "retrieve the status" do 
      assert_received(@itms) { |itms| itms.status(hash_including(options)) }
    end    
  end

  protected
  def options
    { :vendor_id => "VID" } 
  end
end
