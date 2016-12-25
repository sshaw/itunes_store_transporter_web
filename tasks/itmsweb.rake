require "fileutils"
require "delayed/tasks"

rule ".html" => ".md" do |t|
  sh "kramdown < #{t.source} > #{t.name}"
end

task :itmsworker => :environment do
  def kill_um(signal, ids)
    puts "Shutting down..."
    ids.each { |id| Process.kill(signal, id) }
  rescue Errno::ESRCH
    # ignore
  end

  children = []
  %w[notifications jobs update_statuses].each do |name|
    children << fork { Rake::Task["itmsworker:#{name}"].invoke }
  end

  trap("INT") { kill_um("INT", children) }
  trap("TERM") { kill_um("TERM", children) }

  statuses = Process.waitall
  exit statuses.all? { |s| s[1].success? } ? 0 : 1
end

namespace :itmsworker do
  desc "Build standalone worker gem"
  task :build do
    worker = Padrino.root("worker")
    dest = "#{worker}/lib"
    deps = Dir["#{Padrino.root}/models/*.rb"] << "#{Padrino.root}/lib/options.rb"
    deps.each { |path| FileUtils.cp(path, dest) }
    sh "cd #{worker} && gem build *.gemspec"
  end

  task :notifications => :environment do |t|
    options = {
      :quiet  => false,
      :queues => %w[notifications]
    }

    $0 = t.name

    Delayed::Worker.max_attempts = 5

    worker = Delayed::Worker.new(options)
    worker.name = "#{t.name} pid: #$$"
    worker.start
  end

  task :jobs => :environment do |t|
    # Convert website's priority strings to numeric values that DJ can use
    %w[MIN_PRIORITY MAX_PRIORITY].each do |name|
      val = ENV[name]
      if val and !val.empty?
        ENV[name] = if val == "next"
                      name == "MIN_PRIORITY" ? "-1000000" : "-1"
                    else
                      TransporterJob::PRIORITY[val].to_s
                    end
      end
    end

    Delayed::Worker.max_attempts = 1
    Delayed::Worker.max_run_time = 48.hours
    options = {
      :min_priority => ENV["MIN_PRIORITY"],
      :max_priority => ENV["MAX_PRIORITY"],
      :quiet => false,
      :read_ahead => 1
    }

    $0 = t.name
    worker = Delayed::Worker.new(options)
    worker.name = "#{t.name} pid: #$$"
    worker.start
  end

  task :update_statuses => :environment do
    $0 = "update_statuses pid: #$$"

    last_ran = nil
    config = TransporterConfig.first_or_initialize

    loop do
      if config.check_upload_status_at
        now = Time.current
        run_at = config.check_upload_status_at.change(:day => now.day, :month => now.month, :year => now.year)
        if last_ran != run_at && run_at <= now
          # We want this to run before everything
          Delayed::Job.enqueue(StatusCheckJob.new, :priority => -9999999)
          last_ran = run_at
        end
      end

      sleep 60
      # Detect changes to check time
      config.reload
    end
  end
end

namespace :itmsweb do
  task :create_test_directories do
    require "fileutils"

    root = ENV["ROOT"]
    abort "usage: rake test:create_directories ROOT=xxx" unless root

    %w[Harry_Potter_8/X123456.itmsp
       Spiderman/SPIDEY_123456.itmsp
       Spiderman/SPIDEY_123456_UK.itmsp
       random_directory].each do |path|
      FileUtils.mkdir_p(File.join(root, path))
    end
  end

  namespace :docs do
    desc "Generate the help docs"
    docs = Rake::FileList.new("public/docs/*.md") { |fl| fl.exclude("~*") }
    task :build => docs.ext(".html")
  end
end
