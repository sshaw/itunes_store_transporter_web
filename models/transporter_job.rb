require "fileutils"
require "delayed_job"
require "itunes/store/transporter"
require "itunes/store/transporter/errors"

class TransporterJob < ActiveRecord::Base
  STATES = [:queued, :running, :success, :failure]
  STATES.each do |s|
    define_method("#{s}!") { update_attribute(:state, s) }
    define_method("#{s}?") { state == s }
  end

  PRIORITY = Hash.new(0).merge!(:high => -1, :normal => 0, :low => 1)

  attr_protected :state, :target, :job_id

  belongs_to :account

  serialize :result
  serialize :options, Hash
  serialize :exceptions, ITunes::Store::Transporter::TransporterError

  before_save :typecast_options, :assign_target

  after_create  :enqueue_delayed_job
  after_destroy :dequeue_delayed_job, :remove_log

  scope :completed, where(:state => [:success, :failure])

  def self.search(params)
    where(build_search_query(params))
  end

  def command
    self.class.to_s.split(/::/)[-1].sub(/Job/, "")
  end

  def output?
    (log && File.size?(log)).to_i > 0
  end

  def output(offset = 0)
    data = ""
    if log && File.exists?(log)
      File.open(log, "r") do |f|
	f.seek(offset.to_i)
	data = f.read
      end
    end
    data
  end

  def type
    self[:type].sub(/Job\Z/, "") if self[:type]
  end

  def state
    self[:state].to_sym if !self[:state].blank?
  end

  def completed?
    success? || failure?
  end

  # Mixin...
  def haml_object_ref
    "job"
  end

  # @job.execute
  # @job.delay.execute
  # def execute
  # end

  def perform
    save! if new_record?
    options[:log] = log
    running!
    update_attribute(:result, run)
  ensure
    options.delete(:log)
  end

  # job is Delayed::Backend::ActiveRecord::Job
  def enqueue(job)
    queued!
  end

  def success(job)
    success!
  end

  def error(job, exception)
    update_attributes({:state => :failure, :exceptions => exception}, :without_protection => true)
  end

  def failure
    failure!
  end

  def priority
    self[:priority].respond_to?(:to_sym) ? self[:priority].to_sym : :normal
  end

  def to_s
    return "" unless type

    s = "#{type} Job"
    s << ": #{target}" if target.present?
    s
  end

  protected
  def numeric_priority
    # Lower number == higher priority
    priority == :next ?
      [ Delayed::Job.minimum(:priority).to_i, 0 ].min - 1 :
      PRIORITY[priority]
  end

  def enqueue_delayed_job
    connection.transaction do
      # Uh, why not just has_one..?
      job = Delayed::Job.enqueue(self, :priority => numeric_priority)
      update_column :job_id, job.id
    end
  end

  def dequeue_delayed_job
    # what if running... raise error?
    Delayed::Job.delete(job_id) if queued?
  end

  def assign_target
    self.target = _target
  end

  def _target
    # An ID to denote the job's target. E.g., package name, apple id, ...
  end

  def typecast_options
    # For subclasses
  end

  def to_bool(val)
    case val
      when String
	val == "true" || val == "1" ? true : false
      when Fixnum
	val == 1 ? true : false
      else
	val
    end
  end

  def log
    if id?
      @log ||= File.join(config.output_log_directory || ".", "#{id}.log")
    end
  end

  def remove_log
    FileUtils.rm_f(log) if log && File.file?(log)
  end

  def itms
    @itms ||= ITunes::Store::Transporter.new(:path => config.path,
					     :print_stdout => true,
					     :print_stderr => true)
  end

  def config
    @confg ||= AppConfig.first_or_initialize
  end

  def self.build_search_query(where)
    q = {}
    [:priority, :target, :type, :state, :account_id].each { |k| q[k] = where[k] if where[k].present? }

    d = []
    d << where[:updated_at_from].to_date if where[:updated_at_from].present?
    d << where[:updated_at_to].to_date + 1.day if where[:updated_at_to].present?
    q[:updated_at] = d.size == 1 ? d.shift : Range.new(*d) if d.any?

    q
  end
end
