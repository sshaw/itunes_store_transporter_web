class ChangeTransporterJobExceptionsLength < ActiveRecord::Migration
  def self.up
    # Without nil we inherit old length
    change_column :transporter_jobs, :exceptions, :text, :limit => nil
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "rolling back may truncate column data"
  end
end
