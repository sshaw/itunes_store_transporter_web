class AddIndexesToTransporterJobs < ActiveRecord::Migration
  @columns = [:priority, :target, :type, :state, :created_at, :updated_at]
  def self.up
    @columns.each { |name| add_index :transporter_jobs, name }
  end

  def self.down
    @columns.each { |name| remove_index :transporter_jobs, name }
  end
end
