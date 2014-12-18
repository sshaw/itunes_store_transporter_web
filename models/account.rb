class Account < ActiveRecord::Base
  has_many :jobs, :class_name => "TransporterJob"

  validates :username, :shortname, :presence => true
  validates :shortname, :uniqueness => { :case_sensitive => false, :scope => :username }
end
