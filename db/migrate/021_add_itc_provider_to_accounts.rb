class AddITCProviderToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :itc_provider, :string, :limit => 64
  end

  def self.down
    remove_column :accounts, :itc_provider
  end
end
