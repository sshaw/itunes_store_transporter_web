class AddTransporterJobTarget < ActiveRecord::Migration
  def self.up
    add_column :transporter_jobs, :target, :string
  end

  def self.down
    remove_column :transporter_jobs, :target
  end
end
