class CreatePackages < ActiveRecord::Migration
  def self.up
    create_table :packages do |t|
      t.string :title, :null => false
      t.string :vendor_id, :limit => 64, :null => false
      t.string :current_status, :limit => 32
      t.datetime :last_upload
      t.datetime :last_status_check
      t.timestamps

      t.belongs_to :account, :foreign_key => true, :null => false
      t.index :vendor_id, :unique => true
      t.index :current_status
      t.index :last_upload
      t.index :last_status_check
      t.index :updated_at
    end
  end

  def self.down
    drop_table :packages
  end
end
