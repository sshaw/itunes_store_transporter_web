require "yaml"
require "logger"
require "optparse"
require "daemons"
require "delayed_job"
require "delayed/worker"
require "active_record"

# More or less stolen from Delayed::Command: https://github.com/collectiveidea/delayed_job/blob/master/lib/delayed/command.rb

options = { :quiet => true }

opts = OptionParser.new do |opts|
  opts.banner = "usage: #$0 [options] start|stop|restart|run"

  opts.on('-h', '--help', 'Show this message') do
    puts opts
    exit 1
  end

  opts.on('-d', '--daemon', 'Run as a daemon') do
    options[:daemon] = true
  end

  opts.on('--exit-on-complete', "Exit when no more jobs are available to run. This will exit if all jobs are scheduled to run in the future.") do
    options[:exit_on_complete] = true
  end

  opts.on('-i', '--identifier=n', 'A numeric identifier for the worker.') do |n|
    options[:identifier] = n
  end

  opts.on('-l', '--log=name', 'A numeric identifier for the worker.') do |log|
    options[:logfile] = log
  end

  opts.on('-m', '--monitor', 'Monitor and restart crashed instances (automatically sets the --daemon option)') do
    options[:daemon]  = true
    options[:monitor] = true
  end

  opts.on('--min-priority=N', 'Minimum priority of jobs to run.') do |n|
    options[:min_priority] = n
  end

  opts.on('--max-priority=N', 'Maximum priority of jobs to run.') do |n|
    options[:max_priority] = n
  end

  opts.on('-n', '--number-of-workers=COUNT', "Number of unique workers to spawn") do |worker_count|
    options[:worker_count] = worker_count.to_i rescue 1
  end

  opts.on('--pid=DIR', 'Specifies a directory in which to store the process ids.') do |dir|
    options[:pid_dir] = dir
  end

  opts.on('-p', '--prefix=NAME', "String to be prefixed to worker process names") do |prefix|
    options[:prefix] = prefix
  end

  opts.on('--queues=queues', "Specify which queue DJ must look up for jobs") do |queues|
    options[:queues] = queues.split(',')
  end

  opts.on('--queue=queue', "Specify which queue DJ must look up for jobs") do |queue|
    options[:queues] = queue.split(',')
  end

  opts.on('--sleep-delay=N', "Amount of time to sleep when no jobs are found") do |n|
    options[:sleep_delay] = n.to_i
  end
end

path = opts.parse!(ARGV)
abort "config file required" unless path.any?
ActiveRecord::Base.establish_connection(YAML.load_file(path[0]))

# ActiveRecord class, must require *after* connecting
require "transporter_job"

module ITunes::Store::Transporter
  module Web
    class Worker
      PROCESS_NAME = "itmsweb_worker"

      def initialize(options)
        @options = options.dup
        @daemon = @options.delete(:daemon)
        @monitor = @options.delete(:monitor)
        @logfile = @options.delete(:logfile)
        @worker_count = @options.delete(:worker_count) || 1

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
        dir = nil
        #dir = options[:pid_dir]
        #Dir.mkdir(dir) unless File.exists?(dir)

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
        # :dir => dir,
        # :ARGV => args
        Daemons.run_proc(process_name, :dir_mode => :normal, :monitor => @monitor) do |*args|
          $0 = File.join(options[:prefix], process_name) if options[:prefix]
          Delayed::Worker.after_fork
          run process_name
        end
      end

      def run(worker_name = nil)
        Delayed::Worker.read_ahead = 1
        Delayed::Worker.max_attempts = 1
        Delayed::Worker.logger ||= Logger.new(@logfile || STDERR)

        worker = Delayed::Worker.new(@options)
        worker.name_prefix = "#{worker_name} "
        worker.start
      rescue => e
        STDERR.puts e.message
        exit 1
      end
    end
  end
end

# command option
worker = ITunes::Store::Transporter::Web::Worker.new(options)
worker.execute
