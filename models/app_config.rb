require "options"
require "itunes/store/transporter/shell"

class AppConfig < ActiveRecord::Base
  include Options::Validations::Upload

  self.table_name = "config"
  cattr_accessor :output_log_directory

  def self.instance
    first || new
  end

  def path
    self[:path] || ITunes::Store::Transporter::Shell.default_path        
  end  
end


