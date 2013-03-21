module JobFormTestMethods
  def should_behave_like_a_job_form
    should validate_presence_of :username
    should validate_presence_of :password

    context "#marshal_dump" do
      should "include the job's priority" do
	options = self.class.described_type.new(:priority => 1).marshal_dump
	assert_equal 1, options[:priority]
      end
    end
  end

  def should_require_a_package
    should allow_value("123.itmsp").for(:package)
    should_not allow_value("123", "123.itms").for(:package)
  end
end
