class CreateConfig < ActiveRecord::Migration 
  def self.up
    create_table :config, :force => true do |t|
      t.string :username, :limit => 64
      t.string :password, :limit => 64
      t.string :shortname, :limit => 64
      t.string :transport, :limit => 16
      t.string :path
      t.integer:rate
      t.string :output_file_root
      t.string :jvm
    end
  end

  def self.down
    drop_table :config
  end
end
