class AddTransporterJobPriority < ActiveRecord::Migration
  def self.up
    add_column :transporter_jobs, :priority, :string, :limit => 10, :null => false, :default => "normal"
  end

  def self.down
    remove_column :transporter_jobs, :priority
  end
end
