require "options"
require "itunes/store/transporter/shell"

class AppConfig < ActiveRecord::Base
  include Options::Validations::Upload

  self.table_name = "config"

  cattr_accessor :file_browser_root_directory
  cattr_accessor :output_log_directory

  cattr_accessor :allow_select_transporter_path
  self.allow_select_transporter_path = true

  def path
    self[:path] || ITunes::Store::Transporter::Shell.default_path
  end  
end
