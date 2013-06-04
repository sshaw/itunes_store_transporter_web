require File.expand_path('../config/boot.rb', __FILE__)
require 'padrino-core/cli/rake'
require 'delayed/tasks'
require 'fileutils'

PadrinoTasks.init

task :build_worker do
  root = "worker"
  dest = "#{root}/lib"
  deps = Dir["models/*.rb"] << %w[lib/options.rb]
  deps.each { |path| FileUtils.cp(path, dest) }
  sh "cd #{root} && gem build *.gemspec"
end

namespace :jobs do
  # Override the DelayedJob task of the same name and use options that are more suitable
  # for a Transporter workflow (:read_ahead and :max_attempts, rm :queues). Note that max_attempts can't be set via @worker_options.
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
    @worker_options = {
      :min_priority => ENV['MIN_PRIORITY'],
      :max_priority => ENV['MAX_PRIORITY'],
      :quiet => false,
      :read_ahead => 1
    }
  end
end
