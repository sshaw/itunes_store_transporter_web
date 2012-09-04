module FormActions
  %w[username password shortname].each do |field|
    define_method("fill_in_#{field}")  do |val|
      fill_in field.capitalize, :with => val
    end
  end  
  
  def fill_in_auth
    fill_in "Username", :with => options[:username]
    fill_in "Password", :with => options[:password]
    fill_in "Shortname", :with => options[:shortname]
  end
  
  def fill_in_package(val)
    find("#selected_package").set(val)
  end
  
  def set_defaults(optz = options)
    config = AppConfig.instance
    config.update_attributes(optz)
    config
  end
  
  def options
    { :username  => "sshaw", 
      :password  => "--><--",
      :shortname => "pequena" }
  end
end
