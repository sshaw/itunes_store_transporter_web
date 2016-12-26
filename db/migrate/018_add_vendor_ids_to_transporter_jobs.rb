class AddVendorIdsToTransporterJobs < ActiveRecord::Migration
  def self.up
    change_table :transporter_jobs do |t|
      t.text :vendor_ids
    end
  end

  def self.down
    change_table :transporter_jobs do |t|
      t.remove :vendor_ids
    end
  end
end
