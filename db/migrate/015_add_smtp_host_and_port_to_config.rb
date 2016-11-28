class AddSmtpHostAndPortToConfig < ActiveRecord::Migration
  def self.up
    change_table :config do |t|
      t.string :smtp_host
      t.integer :smtp_port
    end
  end

  def self.down
    change_table :config do |t|
      t.remove :smtp_host
      t.remove :smtp_port
    end
  end
end
