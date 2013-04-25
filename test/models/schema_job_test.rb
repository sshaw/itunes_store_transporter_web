require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class SchemaJobTest < Test::Unit::TestCase  
  subject { SchemaJob.new :options => options }

  should_behave_like_a_transporter_job
  should_have_the_command_name("Schema")
  should_have_the_target_name("filmX-strict")
  should_have_the_target_name_when_stringified

  context "#perform" do 
    setup do 
      stub(@itms={}).schema
      stub(subject).itms { @itms }
      subject.perform
    end

    should "retrieve the schema" do
      assert_received(@itms) { |itms| itms.schema(hash_including(options)) }
    end    
  end
  
  protected
  def options
    { :type => "strict", :version => "filmX" } 
  end
end
