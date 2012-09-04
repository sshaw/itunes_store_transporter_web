class AddTransporterJobJobId < ActiveRecord::Migration
  def self.up
    add_column :transporter_jobs, :job_id, :integer
  end

  def self.down
    remove_column :transporter_jobs, :job_id
  end
end
