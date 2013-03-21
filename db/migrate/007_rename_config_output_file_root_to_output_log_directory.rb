class RenameConfigOutputFileRootToOutputLogDirectory < ActiveRecord::Migration
  def self.up
    rename_column :config, :output_file_root, :output_log_directory
  end

  def self.down
    rename_column :config, :output_log_directory, :output_file_root
  end
end
