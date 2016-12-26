class AddSmtpHostAndPortAndStatusCheckToConfig < ActiveRecord::Migration
  def self.up
    change_table :config do |t|
      t.time :check_upload_status_at
      t.string :smtp_host
      t.integer :smtp_port
    end
  end

  def self.down
    change_table :config do |t|
      t.remove :check_upload_status_at
      t.remove :smtp_host
      t.remove :smtp_port
    end
  end
end
