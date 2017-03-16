require "fileutils"
require "delayed/tasks"

rule ".html" => ".md" do |t|
  sh "kramdown < #{t.source} > #{t.name}"
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

  %w[hooks notifications].each do |name|
    task name => :environment do |t|
      options = {
        :quiet  => false,
        :queues => [name]
      }

      $0 = t.name

      worker = Delayed::Worker.new(options)
      worker.name = "#{t.name} pid: #$$"
      worker.start
    end
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
