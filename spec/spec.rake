begin
  require 'rspec/core/rake_task'

  def self.spec_glob(root = 'spec')
    "#{root}/**/*_spec.rb"
  end

  tests = Dir[spec_glob].map { |path| File.dirname(path) }.uniq
  tests.each do |path|
    dirs = path.split('/')
    desc "Run specs in #{dirs[1]}"
    RSpec::Core::RakeTask.new("spec:#{dirs[1]}") do |t|
      t.pattern = spec_glob("spec/#{dirs[1]}")
      t.verbose = true
    end
  end

  desc 'Run application test suite'
  RSpec::Core::RakeTask.new do |t|
    t.verbose = true
  end
rescue LoadError
  task :spec do
    puts "RSpec is not part of this bundle, skip specs."
  end
end

task :default => 'spec'
