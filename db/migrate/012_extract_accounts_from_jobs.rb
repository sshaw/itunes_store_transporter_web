class ExtractAccountsFromJobs < ActiveRecord::Migration
  def self.up
    TransporterJob.select("id,options").where(:account_id => nil).find_each(:batch_size => 10_000) do |job|
      account = Account.find_or_initialize_by_username_and_shortname(*job.options.values_at(:username, :shortname))

      # We assume a newer record's password is correct so we override the older one -if any
      Account.transaction do
        account.update_attributes!(:password => job.options[:password], :shortname => job.options[:shortname])
        account.jobs << job
      end
    end
  end

  def self.down
    Account.delete_all
    TransporterJob.update_all(:account_id => nil)
  end
end
