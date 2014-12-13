class ChangeTransporterJobsOptionsLength < ActiveRecord::Migration
  def self.up
    change_column :transporter_jobs, :options, :string, :limit => 1024
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "rolling back may truncate column data"
  end
end
