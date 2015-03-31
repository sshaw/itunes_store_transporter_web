class Account < ActiveRecord::Base
  has_many :jobs, :class_name => "TransporterJob"

  validates :username, :presence => true
  validates :shortname, :uniqueness => { :case_sensitive => false, :scope => :username }, :if => :shortname?
  validates :alias, :presence => true
  validates :alias, :format => { :with => /[^\s]/ }, :if => :alias?
  validates :alias, :uniqueness => { :case_sensitive => false }, :if => :alias?

  def display_name
    self.alias.presence || username
  end
end
