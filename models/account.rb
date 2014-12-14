class Account < ActiveRecord::Base
  has_many :jobs, :class_name => "TransporterJob"

  validates :username, :shortname, :presence => true
  validates :username, :uniqueness => { :case_sensitive => false }
end
