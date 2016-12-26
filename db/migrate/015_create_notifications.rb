class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.string :name, :limit => 32, :null => false
      t.string :from, :null => false, :limit => 64
      t.string :to, :null => false, :limit => 128
      t.string :subject, :null => false, :limit => 128
      t.string :reply_to, :limit => 64
      t.text :message
      t.timestamps

      t.belongs_to(:account, :foreign_key => true, :null => false, :index => { :unique => true })
    end

    [:transporter_jobs, :accounts].each do |table|
      add_column table, :disable_notification, :boolean, :default => false, :null => false
    end
  end

  def self.down
    drop_table :notifications

    [:transporter_jobs, :accounts].each do |table|
      remove_column table, :disable_notification
    end
  end
end
