require "options"
require "itunes/store/transporter/shell"

class AppConfig < ActiveRecord::Base
  include Options::Validations::Upload

  self.table_name = "config"

  cattr_accessor :file_browser_root_directory
  cattr_accessor :allow_select_transporter_path
  self.allow_select_transporter_path = true

  def self.output_log_directory
    @@output_log_directory
  end

  def self.output_log_directory=(path)
    config = first_or_initialize
    config.update_attribute(:output_log_directory, path) if config.output_log_directory != path
  end

  # DB column name is path
  def path
    self[:path] || ITunes::Store::Transporter::Shell.default_path
  end
end
