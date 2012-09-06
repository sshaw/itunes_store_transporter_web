require "fileutils"
require "delayed_job"
require "itunes/store/transporter/errors"

# Delayed::Worker.read_ahead set to one so that other workdrs can pull jobs instead of one taking 5 from the gate

class TransporterJob < ActiveRecord::Base  
  STATES = [:queued, :running, :success, :failure]
  STATES.each do |s|
    define_method("#{s}!") { update_attribute(:state, s) }
    define_method("#{s}?") { state == s }
  end

  attr_protected :state

  serialize :result
  serialize :options, Hash
  serialize :exceptions, ITunes::Store::Transporter::TransporterError

  before_save :typecast_options

  after_create  :enqueue_delayed_job
  after_destroy :dequeue_delayed_job, :remove_log

  def command
    self.class.to_s.split(/::/)[-1].sub(/Job/, "")
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
    self[:type].sub(/Job$/, "") if self[:type]
  end

  def state    
    self[:state].to_sym if !self[:state].blank?
  end

  def done?
    !queued? && !running?
  end

  # An ID to denote the job's target. E.g., package name, apple id, ...  
  def target
    ""
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
    save! if new_record? #changed? check of already ran
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
    failure!
    update_attribute(:exceptions, exception)
  end

  def failure
    # diff between this and error?
  end  

  def to_s
    return "" unless type

    s = "#{type} Job"
    s << ": #{target}" if target.present?
    s
  end

  protected
  def enqueue_delayed_job
    job = Delayed::Job.enqueue(self) 
    update_column :job_id, job.id
  end

  def dequeue_delayed_job
    # what if running... raise error?
    Delayed::Job.delete(job_id) if queued?
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
end
