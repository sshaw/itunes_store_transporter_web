require "erb"
require "tempfile"
require "fileutils"

begin
  require "rubygems"
rescue LoadError => e
  $stderr.puts "RubyGems is not installed. Download and install it first: http://rubygems.org/pages/download"
  exit 1
end

def config_database
  config  = { :database => DBNAME }
  drivers = [
    [:MySQL,  "mysql2" ],
    [:SQLite, "sqlite3" ],
    # Just for now...
  ]

  puts "Select your database: "
  drivers.each_with_index { |name, i| puts "#{i + 1}: #{name[0]}" }
  i = gets
  unless i =~ /\A\d+\Z/ && (pos = i.to_i - 1) >= 0 && pos < drivers.size
    puts "Unknown choice '#{i.chomp}'"
    exit
  end

  config[:gem] = drivers[pos][1]
  config[:adapter] = drivers[pos][1]

  if config[:adapter] == "sqlite3"
    path = "#{ROOT}/db"
    Dir.mkdir(path) unless File.directory?(path)
    config[:database] = "#{path}/#{DBNAME}.sqlite3"
    return config
  end

  [:host, :username, :password].each do |opt|
    print "#{opt.to_s.capitalize}: "
    config[opt] = gets.chomp
  end

  config[:host] = "localhost" unless config[:host] =~ /\w/
  config
end

DBNAME = "itmsweb"
ROOT = File.expand_path(File.dirname(__FILE__))

print "Internet access required, is this OK? [y/N]: "
opt = gets
exit unless opt =~ /\Ay/i

config  = config_database
gemfile = "Gemfile.#{RUBY_PLATFORM}"

FileUtils.cp("Gemfile", gemfile)
File.open(gemfile, "a") { |io| io.puts "gem '#{config[:gem]}'" }

puts "Installing dependencies"

commands = ["bundle install --path vendor/bundle --without=test development --binstubs --gemfile=#{gemfile}"]

begin
  # Just look up gem!
  Gem.bin_path "bundler", "bundle"
rescue Gem::GemNotFoundException => e
  commands.unshift "gem install bundler"
end

commands.each do |cmd|
  puts cmd
  abort "Installation failed" unless system cmd
end

config.delete(:gem)
File.open("config/database.rb", "w") { |io| io.puts DATA.read }
File.open("config/database.yml", "w") do |io|
  io.puts ERB.new(<<'T').result(binding)
---
<%= config.map { |k,v| %(#{k}: "#{v}") }.join "\n" %>
T
end

ENV["BUNDLE_GEMFILE"] = "#{ROOT}/#{gemfile}"
abort "Installation failed" unless system "bin/padrino rake -e production ar:setup"

File.delete(*Dir["bin/*"].reject { |path|
  %w[padrino itmsweb itmsweb_worker.rb].include? File.basename(path)
})

worker = "bin/itmsweb_worker"
File.open(worker, "w") do |io|
  io.puts <<END
#!/bin/bash
BUNDLE_GEMFILE="#{ENV['BUNDLE_GEMFILE']}" ruby #{ROOT}/bin/itmsweb_worker.rb
END
end

File.chmod(555, worker)
FileUtils.mkdir_p("var/lib/output")
puts "Installation complete, be sure to setup the iTMSTransporter output log directory, see the docs for more info"

__END__
ActiveRecord::Base.configurations[:production] = YAML.load_file(Padrino.root("config/database.yml"))
ActiveRecord::Base.logger = logger
ActiveRecord::Base.mass_assignment_sanitizer = :strict
ActiveRecord::Base.auto_explain_threshold_in_seconds = 0.5
ActiveRecord::Base.include_root_in_json = false
ActiveRecord::Base.store_full_sti_class = true
ActiveSupport.use_standard_json_time_format = true
ActiveSupport.escape_html_entities_in_json = false
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Padrino.env])
