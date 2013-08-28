require "erb"
require "tempfile"
require "fileutils"

begin
  require "rubygems"
rescue LoadError => e
  $stderr.puts "RubyGems is not installed. Download and install it first: http://rubygems.org/pages/download"
  exit 1
end

def windows?
  Gem.win_platform?
end

def config_database
  config  = { :name => DBNAME }
  drivers = [
    # Just for now... ultimately will need installer class for each gem that
    # will install all mods (e.g., JDBC + ActiveRecord adapter), set cfg options, ...
    %w[MySQL mysql2],
    %w[PostgreSQL pg postgresql],
    %w[SQLite sqlite3]
  ]

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
RAKE = "bin/padrino rake -e production"
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
abort "Installation failed" unless system "#{RAKE} ar:migrate"

File.delete(*Dir["bin/*"].reject { |path|
  %w[padrino itmsweb].include? File.basename(path)
})

worker = "#{ROOT}/bin/itmsworker"
worker << ".bat" if windows?
File.open(worker, "w") do |io|
  env = %|BUNDLE_GEMFILE="#{ENV["BUNDLE_GEMFILE"]}"|
  cmd = "#{RAKE} jobs:"

  if windows?
    # check this
    io.puts <<-BAT
@echo off
set #{env}"
set task=%1
if "%task%" == "" (
  set task=work
)
#{cmd}%task%
    BAT
  else
    io.puts <<-SH 
#!/bin/bash
#{env} #{cmd}${1:-work}
    SH
  end
end

File.chmod(0555, worker)
