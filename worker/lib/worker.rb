require "logger"
require "daemons"
require "delayed_job"
require "delayed/worker"
require "active_support/dependencies"

ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__)

# More or less stolen from Delayed::Command: https://github.com/collectiveidea/delayed_job/blob/master/lib/delayed/command.rb

class Worker
  PROCESS_NAME = "itmsweb_worker"

  def initialize(options)
    @options = options.dup
    @options[:queues] = @options[:queues].split(",") if @options[:queues]

    @monitor = @options.delete(:monitor)

    @daemon = @options.delete(:daemon)
    @daemon = true if @monitor

    @worker_count = @options.delete(:worker_count).to_i
    @worker_count = 1 if @worker_count < 1

    @logfile = @options.delete(:log)

    Delayed::Worker.backend = :active_record
  end

  def execute
    if @daemon
      daemonize
    else
      run
    end
  end

  private
  def daemonize
    if dir = @options[:pid]
      Dir.mkdir(dir) unless File.exists?(dir)
    end

    if @worker_count > 1 && @options[:identifier]
      raise ArgumentError, 'Cannot specify both --number-of-workers and --identifier'
    elsif @worker_count == 1 && @options[:identifier]
      process_name = "#{PROCESS_NAME}.#{options[:identifier]}"
      run_process(process_name, dir)
    else
      threads = []
      @worker_count.times do |worker_index|
        threads << Thread.start do
          process_name = @worker_count == 1 ? PROCESS_NAME : "#{PROCESS_NAME}.#{worker_index}"
          run_process(process_name, dir)
        end
      end
      threads.each(&:join)
    end
  end

  def run_process(process_name, dir)
    Delayed::Worker.before_fork
    Daemons.run_proc(process_name, :dir => dir, :dir_mode => :normal, :ARGV => @options[:argv], :monitor => @monitor) do |*args|
      $0 = File.join(@options[:prefix], process_name) if @options[:prefix]
      # TODO: What to do here? Each thread needs a connection but the will call AR.establish_conn w/o args
      # Delayed::Worker.after_fork
      run process_name
    end
  end

  def run(worker_name = nil)
    Delayed::Worker.read_ahead = 1
    Delayed::Worker.max_attempts = 1
    # TODO: this can be shared by many threads
    Delayed::Worker.logger ||= Logger.new(@logfile) if @logfile

    worker = Delayed::Worker.new(@options)
    worker.name_prefix = "#{worker_name} "
    worker.start
  rescue => e
    STDERR.puts e.message
    exit 1
  end
end
