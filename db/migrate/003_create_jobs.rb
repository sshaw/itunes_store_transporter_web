class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :transporter_jobs do |t|
      t.string :state, :limit => 16
      t.string :options
      t.text   :result
      t.string :exceptions
      t.string :output_log_file
      t.string :type, :limit => 32
      t.timestamps
    end
  end

  def self.down
    drop_table :transporter_jobs
  end
end
