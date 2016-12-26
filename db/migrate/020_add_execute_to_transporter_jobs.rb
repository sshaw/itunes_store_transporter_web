class AddExecuteToTransporterJobs < ActiveRecord::Migration
  def self.up
    change_table :transporter_jobs do |t|
      t.string :execute, :limit => 1024 # match OS X path limit
    end
  end

  def self.down
    change_table :transporter_jobs do |t|
      t.remove :execute
    end
  end
end
