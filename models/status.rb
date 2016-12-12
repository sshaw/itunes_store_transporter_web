class Status < ActiveRecord::Base
  belongs_to :package

  validates :time, :presence => true
  validates :name, :presence => true
  validates :package, :presence => true
end
