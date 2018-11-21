require "erb"
require "fileutils"
require "yaml"
require "optparse"

abort "Ruby >= 1.9 and < 2.5 is required, you're running #{RUBY_VERSION}" if RUBY_VERSION < "1.9" || RUBY_VERSION >= "2.5.0"

DBNAME = "itmsweb"
RAKE = "ruby bin/padrino rake -e production"
ROOT = File.dirname(__FILE__)

DBDependency = Struct.new(:name, :gem, :adapter, :version) do
  def to_gem
    s = "gem '#{gem}'"
    s << ", '#{version}'" if version
    s
  end

  def adapter
    self[:adapter] || gem
  end
end

$config = {
  :db_name => DBNAME,
  :prompt => true
}

$supported_drivers = [
  DBDependency.new("SQLite", "sqlite3"),
  DBDependency.new("MySQL", "mysql2", nil, "~> 0.3.18"),
  DBDependency.new("PostgreSQL", "postgresql", "pg")
]

$default_driver = $supported_drivers[0]

parser = OptionParser.new do |opts|
  opts.banner = "usage: #{File.basename($0)} [--db-driver=name] [--db-user=name] [--db-password=name] [--db-host=name] [--no-prompt]"

  opts.on "-h", "--help", "Show this message" do
    puts opts
    exit
  end

  opts.on "--[no-]prompt", "Prompt or don't prompt user for config options" do |prompt|
    $config[:prompt] = prompt
  end

  opts.on "--[no-]config", "Do not create a config file" do |config|
    $config[:config] = config
  end

  opts.on "--db-driver=NAME", $supported_drivers.map { |d| d.name.downcase }, "DB driver" do |name|
    $config[:db_driver] = $supported_drivers.find { |d| d.name.downcase == name }
  end

  opts.on "--db-password=NAME", "DB password" do |name|
    $config[:db_password] = name
  end

  opts.on "--db-host=NAME", "DB hostname" do |name|
    $config[:db_host] = name
  end

  opts.on "--db-user=NAME", "DB username" do |name|
    $config[:db_user] = name
  end
end.parse!

def prompt_for_config
  unless $config[:db_driver]
    puts "Select your database: "
    $supported_drivers.each_with_index { |dep, i| puts "#{i + 1}: #{dep.name}" }

    i = gets
    exit unless i # EOF
    abort "Unknown choice '#{i.chomp}'" unless i =~ /\A\d+\Z/ && $supported_drivers[pos = i.to_i - 1]
    $config[:db_driver] = $supported_drivers[pos]
  end

  return if $config[:db_driver].name == "SQLite"

  unless $config[:db_host]
    print "Database host [localhost]: "
    host = gets
    exit unless host

    $config[:db_host] = host.chomp if host =~ /\w/
  end

  %w[user password].each do |opt|
    key = :"db_#{opt}"
    next if $config[key]

    print "Database #{opt}: "
    choice = gets
    exit unless choice

    $config[key] = choice.chomp
  end
end

def install
  puts "Installing..."

  db_driver = $config[:db_driver] || $default_driver
  db_config = {
    "name" => $config[:db_name],
    "adapter" => db_driver.adapter,
    "host" => $config[:db_host] || "localhost",
    "username" => $config[:db_username],
    "password" => $config[:db_password],
  }

  if db_config["adapter"] == "sqlite3"
    path = "#{ROOT}/db"
    Dir.mkdir(path) unless File.directory?(path)
    db_config["name"] = "#{path}/#{$config[:db_name]}}.sqlite3"
    db_config["timeout"] = 5000
  end

  unless $config[:config]
    File.open("#{ROOT}/config/itmsweb.yml", "w") do |io|
      io.puts YAML.dump("database" => db_config)
    end
  end

  gemfile = "#{ROOT}/Gemfile.#{RUBY_PLATFORM}"
  FileUtils.cp("#{ROOT}/Gemfile", gemfile)
  # SQLite is in the Gemfile by default
  File.open(gemfile, "a") { |io| io.puts db_driver.to_gem }

  ENV["BUNDLE_GEMFILE"] = gemfile

  # TODO: update these in 0.2.0 to use new Bundler options
  commands = ["bundle install --path vendor/bundle --without=test development --binstubs",
              "#{RAKE} ar:setup"]
  begin
    # Just look up gem?
    Gem.bin_path "bundler", "bundle"
  rescue Gem::GemNotFoundException => e
    commands.unshift "gem install bundler --no-rdoc"
  end

  commands.each do |cmd|
    puts cmd
    abort "Installation failed" unless system cmd
  end

  # Remove unneeded files created by bundle --binstubs
  File.delete(*Dir["bin/*"].reject { |path|
    %w[padrino itmsweb itmsworker].include?(File.basename(path).sub(/\.\w+\Z/, ""))
  })

  # iTMSTransporter logs go here by default
  FileUtils.mkdir_p("#{ROOT}/var/lib/output")
end

prompt_for_config if $config[:prompt]
install

puts(<<MSG)
Installation successful!
You can now start the website and the queue worker using the following commands:

bin/itmsweb start
bin/itmsworker

Please report any issues at https://github.com/sshaw/itunes_store_transporter_web/issues.

Thanks for using the iTunes Store Transporter: GUI.
http://transportergui.com

Made by ScreenStaring
http://screenstaring.com
---

MSG
