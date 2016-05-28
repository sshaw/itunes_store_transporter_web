require "options"
require "itunes/store/transporter/shell"

class TransporterConfig < ActiveRecord::Base
  include Options::Validations::Upload

  self.table_name = "config"

  def self.output_log_directory=(path)
    config = first_or_initialize
    config.update_attribute(:output_log_directory, path) if config.output_log_directory != path
  end

  # DB column name is path
  def path
    self[:path] || ITunes::Store::Transporter::Shell.default_path
  end
end

# Backwards compatibility
AppConfig = TransporterConfig
