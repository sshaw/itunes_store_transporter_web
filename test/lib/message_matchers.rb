module MessageMatchers
  def package_blank?
    has_content?("Package can't be blank")
  end

  def package_name_invalid?
    has_content?('Package must end with ".itmsp"')
  end
  
  def rate_not_number?
    has_content?("Rate is not a number")
  end

  def rate_gt_zero?
    has_content?("must be greater than 0")
  end  
  
  def job_added_message?
    klass = self.class.to_s.gsub /ControllerTest\z/, ""
    has_content?("#{klass} job added to the queue")
  end
end
