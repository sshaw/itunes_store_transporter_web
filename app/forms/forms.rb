require "ostruct"
require "options"
require "rexml/document"

class JobForm < OpenStruct
  include ActiveModel::Validations

  validates_presence_of :account_id
  validate :find_account, :unless => lambda { |r| r.account_id.blank? }

  def marshal_dump
    options = super.dup.except(:account_id, :disable_notification, :execute)

    if @account
      options[:username]  = @account.username
      options[:password]  = @account.password
      options[:shortname] = @account.shortname
    end

    data = { :options => options, :account_id => account_id, :execute => execute }
    data[:disable_notification] = disable_notification unless disable_notification.nil?
    data[:priority] = data[:options].delete(:priority) if data[:options].include?(:priority)

    data
  end

  protected

  def find_account
    # Avoid raising an exception via find()
    @account = Account.where(:id => account_id).first
    return true if @account

    errors[:account_id] << "unknown"
    false
  end
end

class UploadForm < JobForm
  include Options::Validations::Upload
  include Options::Validations::Package

  validate :check_metadata, :unless => lambda { |form| form.errors.include?(:package) }
  validate :check_executable, :unless => lambda { |form| form.execute.blank? }

  def initialize(options = {})
    super
    @titles = []
    @vendor_ids = []
  end

  def packages
    return [] unless valid?
    build_packages
  end

  def marshal_dump
    super.merge(:vendor_ids => @vendor_ids)
  end

  private

  def get_vendor_id(doc)
    e = doc.get_elements("//video/vendor_id").first
    return e.text.strip if e

    e = doc.get_elements("//assets").first
    return e.attribute("vendor_id").to_s.strip if e && e.attribute("vendor_id")
  end

  def get_title(doc)
    e = doc.get_elements("//video/title").first
    return e.text.strip if e

    vid = get_vendor_id(doc)
    return unless vid

    pkg = Package.select(:title).find_by(:vendor_id => vid)
    return pkg.title if pkg
  end

  def check_executable
    errors.add(:execute, "not an executable file") unless File.file?(execute) && File.executable?(execute)
  end

  def build_packages
    @vendor_ids.map.with_index do |id, i|
      Package.find_or_initialize_by(:vendor_id => id) do |pkg|
        pkg.account_id = account_id
        pkg.title = @titles[i]
      end
    end.uniq
  end

  def check_metadata
    # Don't accumulate between calls to valid?
    @titles.clear
    @vendor_ids.clear
    if batch == "1"
      Dir[ File.join(package, "*.itmsp") ].each { |pkg| extract_title_and_vendor_id(pkg) }
    else
      extract_title_and_vendor_id(package)
    end
  end

  def extract_title_and_vendor_id(pkg)
    path = File.join(pkg, "metadata.xml")
    unless File.file?(path)
      errors.add(:base, "No metadata.xml in #{File.basename(pkg)}")
      return false
    end

    begin
      doc = REXML::Document.new(File.read(path))
    rescue => e
      errors.add(:base, "Metadata problem for #{File.basename(pkg)}: #{e}")
      return false
    end

    vid = get_vendor_id(doc)
    unless vid
      errors.add(:base, "Metadata missing vendor_id in #{File.basename(pkg)}")
      return false
    end

    @vendor_ids << vid

    title = get_title(doc)
    unless title
      errors.add(:base, "Metadata missing title in #{File.basename(pkg)}")
      return false
    end

    @titles << title
  end
end

class VerifyForm < JobForm
  include Options::Validations::Package
end

class SchemaForm < JobForm
  validates_presence_of :version_number
  validates_numericality_of :version_number, :greater_than => 0, :unless => lambda { |form| form.version_number.blank? }
  validates_inclusion_of :version_name, :in => %w[film tv], :message => "Must be film or TV"
  validates_inclusion_of :type, :in => %w[transitional strict], :message => "Must be transitional or strict"

  def marshal_dump
    data = super
    data[:options].except!(:version_name, :version_number)
    data[:options][:version] = [version_name, version_number].compact.join('')
    data
  end
end

class LookupForm < JobForm
  validates_presence_of :package_id_value, :message => "You must provide an Apple ID or Vendor ID"
  validates_inclusion_of :package_id, :in => %w[vendor_id apple_id], :message => "Must be vendor_id or apple_id"

  def marshal_dump
    data = super
    data[:options].except!(:package_id, :package_id_value)
    data[:options][package_id.to_sym] = package_id_value if package_id.respond_to?(:to_sym)
    data
  end
end

class StatusForm < JobForm
  # Without a custom message, the ID is dropped from vendor id when show in the form
  validates_presence_of :vendor_id, :message => "ID can't be blank"
end

class ProvidersForm < JobForm; end
