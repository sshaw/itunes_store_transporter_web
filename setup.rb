require "erb"
require "fileutils"

abort "Ruby >= 1.9 is required, you're running #{RUBY_VERSION}" if RUBY_VERSION < "1.9"

#
# gem install sqlite3 -- --with-sqlite3-include=/opt/local/include --with-sqlite3-lib=/opt/local/lib

def config_database
  config  = { :name => DBNAME }
  drivers = [
    # Just for now... ultimately will need installer class for each gem that
    # will install all mods (e.g., JDBC + ActiveRecord adapter), set cfg options, ...
    %w[MySQL mysql2],
    %w[PostgreSQL pg postgresql],
    %w[SQLite sqlite3]
  ]

  # puts "Do you have an existing database that you want to use?"
  # if yes get driver, username, etc... else DL and install SQLite to vendor/sqlite3
  puts "Select your database: "
  drivers.each_with_index { |name, i| puts "  #{i + 1}: #{name[0]}" }
  i = gets
  unless i =~ /\A\d+\Z/ && (pos = i.to_i - 1) >= 0 && pos < drivers.size
    puts "Unknown choice '#{i.chomp}'"
    exit
  end

  config[:gem] = drivers[pos][1]
  config[:adapter] = drivers[pos][2] || drivers[pos][1]

  if config[:adapter] == "sqlite3"
    path = "#{ROOT}/db"
    Dir.mkdir(path) unless File.directory?(path)
    config[:name] = "#{path}/#{DBNAME}.sqlite3"
    return config
  end

  print "Host [localhost]: "
  config[:host] = gets.chomp
  config[:host] = "localhost" unless config[:host] =~ /\w/
  [:username, :password].each do |opt|
    print "#{opt.to_s.capitalize}: "
    config[opt] = gets.chomp
  end

  config
end

DBNAME = "itmsweb"
RAKE = "ruby bin/padrino rake -e production"
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
File.open("#{ROOT}/config/itmsweb.yml", "w") do |io|
  io.puts ERB.new(<<'T', nil, "<>").result(binding)
---
database:
<% config.each do |k,v| %>
  <%= k %>: <%= v %>
<% end %>
T
end

FileUtils.mkdir_p("#{ROOT}/var/lib/output")
ENV["BUNDLE_GEMFILE"] = "#{ROOT}/#{gemfile}"

# TODO: This should be changed to ar:setup
puts "#{RAKE} ar:migrate"
abort "Installation failed" unless system "#{RAKE} ar:migrate"

# Remove unneeded files created by bundle --binstubs
File.delete(*Dir["bin/*"].reject { |path|
  %w[padrino itmsweb itmsworker].include? File.basename(path).sub(/\.\w+\Z/, "")
})

puts(<<MSG)
Installation successful!
You can now start the website and the queue worker using the following commands:

bin/itmsweb start
bin/itmsworker

Enjoy!
MSG
