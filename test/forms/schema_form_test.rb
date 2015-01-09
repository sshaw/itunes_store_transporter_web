require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class SchemaFormTest < Minitest::Test
  should_behave_like_a_job_form
  should validate_presence_of :version_number
  should validate_numericality_of(:version_number)
  should_not allow_value(-1, 0).for(:version_number)
  should allow_value("film", "tv").for(:version_name)
  should allow_value("transitional", "strict").for(:type)

  context "#marshal_dump" do
    should "return an options hash" do
      expect = {
        :options => {
          :type => "strict",
          :version => "tv5.0"
        }
      }
      
      options = self.class.described_type.new(:type => "strict",
                                              :version_name => "tv",
                                              :version_number => "5.0").marshal_dump
      assert_equal expect, options
    end
  end
end
