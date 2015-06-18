class AddAccountToTransporterJobs < ActiveRecord::Migration
  def self.up
    add_column :transporter_jobs, :account_id, :integer
    add_index :transporter_jobs, :account_id
  end

  def self.down
    remove_column :transporter_jobs, :account_id
  end
end
