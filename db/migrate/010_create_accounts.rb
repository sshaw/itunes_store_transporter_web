class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts, :force => true do |t|
      t.string :username, :limit => 64, :null => false
      t.string :password, :limit => 64, :null => false
      t.string :shortname, :limit => 64
      t.timestamps
    end

    add_index :accounts, [:username, :shortname], :unique => true
  end

  def self.down
    drop_table :accounts
  end
end
