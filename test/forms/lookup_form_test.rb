require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class LookupFormTest < Minitest::Test
  should_behave_like_a_job_form
  should validate_presence_of(:package_id_value).with_message(/Apple ID or Vendor ID/)
  should allow_value("vendor_id", "apple_id").for(:package_id)

  context "#marshal_dump" do
    should "return an options hash" do
      expect = {
        :options => {
          :username => "sshaw",
          :password => "G@tinH@",
          :apple_id => "123"
        }
      }
      options = self.class.described_type.new(:username => "sshaw",
                                              :password => "G@tinH@",
                                              :package_id => "apple_id",
                                              :package_id_value => "123").marshal_dump
      assert_equal expect, options
    end
  end
end
