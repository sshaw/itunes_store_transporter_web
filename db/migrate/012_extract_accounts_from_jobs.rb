class ExtractAccountsFromJobs < ActiveRecord::Migration
  def self.up
    TransporterJob.select("id,options").find_each do |job|
      account = Account.find_or_initialize_by_username_and_shortname(*job.options.values_at(:username, :shortname))
      # We assume a newer record's password is correct so we override the older one -if any
      account.password = job.options[:password]
      account.save!

      account.jobs << job
    end
  end

  def self.down
    Account.delete_all
    TransporterJob.update_all(:account_id => nil)
  end
end
