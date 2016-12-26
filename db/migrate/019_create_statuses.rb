class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.string :name, :limit => 32, :null => false
      t.datetime :time, :null => false
      t.belongs_to :package, :null => false, :foreign_key => true
    end
  end

  def self.down
    drop_table :statuses
  end
end
