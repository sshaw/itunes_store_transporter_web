require "erb"
require "fileutils"
require "yaml"

abort "Ruby >= 1.9 is required, you're running #{RUBY_VERSION}" if RUBY_VERSION < "1.9"

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

def config_database
  config  = { "name" => DBNAME }
  drivers = [
    DBDependency.new("MySQL", "mysql2", nil, "~> 0.3.18"),
    DBDependency.new("PostgreSQL", "postgresql", "pg"),
    DBDependency.new("SQLite", "sqlite3")
  ]

  puts "Select your database: "
  drivers.each_with_index { |dep, i| puts "  #{i + 1}: #{dep.name}" }
  i = gets
  unless i =~ /\A\d+\Z/ && (pos = i.to_i - 1) >= 0 && pos < drivers.size
    abort "Unknown choice '#{i.chomp}'"
  end

  config["adapter"] = drivers[pos].adapter
  config["gem"] = drivers[pos].to_gem

  if config["adapter"] == "sqlite3"
    path = "#{ROOT}/db"
    Dir.mkdir(path) unless File.directory?(path)
    config["name"] = "#{path}/#{DBNAME}.sqlite3"
    config["timeout"] = 5000
    return config
  end

  print "Host [localhost]: "
  config["host"] = gets.chomp
  config["host"] = "localhost" unless config[:host] =~ /\w/
  %w[username password].each do |opt|
    print "#{opt.to_s.capitalize}: "
    config[opt] = gets.chomp
  end

  config
end

def write_config(config)
  File.open("#{ROOT}/config/itmsweb.yml", "w") do |io|
    io.puts YAML.dump("database" => config)
  end
end

def install(config)
  gemfile = "#{ROOT}/Gemfile.#{RUBY_PLATFORM}"
  FileUtils.cp("#{ROOT}/Gemfile", gemfile)
  File.open(gemfile, "a") { |io| io.puts config["gem"] }

  config.delete("gem")
  write_config(config)

  ENV["BUNDLE_GEMFILE"] = gemfile

  puts "Installing dependencies"
  # TODO: update these in 0.2.0 to use new Bundler options
  commands = ["bundle install --path vendor/bundle --without=test development --binstubs",
              "#{RAKE} ar:setup"]
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

  # Remove unneeded files created by bundle --binstubs
  File.delete(*Dir["bin/*"].reject { |path|
    %w[padrino itmsweb itmsworker].include?(File.basename(path).sub(/\.\w+\Z/, ""))
  })

  FileUtils.mkdir_p("#{ROOT}/var/lib/output")
end

print "Internet access required, is this OK? [y/N]: "
opt = gets
exit unless opt =~ /\Ay/i

install(config_database)

puts(<<MSG)
Installation successful!
You can now start the website and the queue worker using the following commands:

bin/itmsweb start
bin/itmsworker

Please report any issues at https://github.com/sshaw/itunes_store_transporter_web/issues.

Thanks for using the Transporter GUI.
http://transportergui.com
MSG
