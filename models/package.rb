require "itunes/store/transporter/web/search"
require "itunes/store/transporter/web/package_status"

class Package < ActiveRecord::Base
  include ITunes::Store::Transporter::Web

  belongs_to :account
  has_many :status_history, :class_name => "Status", :dependent => :destroy

  validates :title, :presence => true
  validates :vendor_id, :presence => true, :uniqueness => true
  validates :account_id, :presence => true

  before_create :set_status
  before_create { vendor_id.strip! }
  before_update :add_status_change_to_history

  def self.search(params)
    Search::Package::Order.new(
      Search::Package::Where.new(self).build(params)
    ).build(params)
  end

  def self.pending_uploads
    st = PackageStatus::ON_STORE
    where(<<-SQL, st, st, 24.hours.ago, 24.hours.ago)
      current_status is null or current_status != ? or current_status = ? and
        (last_upload >= ? and last_status_check <= ? or last_status_check is null)
    SQL
  end

  def to_s
    return "" unless title

    s = title.dup
    s << " - #{vendor_id}" if vendor_id.present?
    s
  end

  private

  def set_status
    upload = UploadJob.select(:state).completed.where(:target => vendor_id).first
    # We don't need to translate this status via PackageStatus
    self[:current_status] = upload.state.to_s.titleize if upload
  end

  def add_status_change_to_history
    # If we changed it from nil there's nothing to add to the history
    if current_status_changed? && !current_status_change[0].nil?
      status_history.build(:name => current_status_change[0], :time => time_of_last_status_change)
    # A check can take place but result in the same state, we still need to track this
    elsif last_status_check_changed? && !last_status_check_change[0].nil? && !current_status.nil?
      status_history.build(:name => current_status, :time => time_of_last_status_change)
    end
  end

  def time_of_last_status_change
    if last_status_check_changed?
      t = last_status_check_change[0]
    elsif last_upload_changed?
      t = last_upload[0]
    end

    t || updated_at || created_at
  end
end
