class AddAlaiasToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :alias, :string, :limit => 32
    add_index :accounts, :alias, :unique => true
  end

  def self.down
    remove_column :accounts, :alias
  end
end
