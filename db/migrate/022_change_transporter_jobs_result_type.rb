class ChangeTransporterJobsResultType < ActiveRecord::Migration
  def change
    return unless ActiveRecord::Base.connection_config[:adapter] == "mysql2"
    change_column :transporter_jobs, :result, "longtext"
  end
end
