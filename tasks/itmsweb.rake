require "fileutils"
require "delayed/tasks"

namespace :itmsworker do
  desc "Build standalone worker gem"
  task :build do
    worker = Padrino.root("worker")
    dest = "#{worker}/lib"
    deps = Dir["#{Padrino.root}/models/*.rb"] << "#{Padrino.root}/lib/options.rb"
    deps.each { |path| FileUtils.cp(path, dest) }
    sh "cd #{worker} && gem build *.gemspec"
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
end

# Override the DelayedJob task of the same name and use options that are more suitable
# for a Transporter workflow (:read_ahead and :max_attempts, rm :queues). Note that max_attempts can't be set via @worker_options.
namespace :jobs do
  task :environment_options => :environment do
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
    @worker_options = {
      :min_priority => ENV["MIN_PRIORITY"],
      :max_priority => ENV["MAX_PRIORITY"],
      :quiet => false,
      :read_ahead => 1
    }
  end
end
