require 'rake/testtask'

test_tasks = Dir['test/*/'].map { |d| File.basename(d) }

test_tasks.each do |folder|
  name = "test:#{folder}"
  Rake::TestTask.new(name) do |test|
    test.pattern = "test/#{folder}/**/*_test.rb"
    test.verbose = true
  end
  #task name => :reset
end

#task :_reset do 
  #PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
  #Rake::Task["ar:reset"].invoke
#end

desc "Run application test suite"
#task 'test' => test_tasks.map { |f| "test:#{f}" }
task :test do
  test_tasks.map { |f| Rake::Task["test:#{f}"].invoke }
end

# [ar:setup, ar:drop]
