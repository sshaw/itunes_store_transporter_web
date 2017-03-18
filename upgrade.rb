require "fileutils"
require "yaml"

def failure(msg)
  abort "upgrade failed: #{msg}"
end

def upgrade_gemfile(gemfile)
  root = File.dirname(gemfile)
  FileUtils.rm("#{gemfile}.lock")

  begin
    config = File.join(root, "config/itmsweb.yml")
    config = YAML.load_file(config)
  rescue => e
    failure("error reading #{config}: #{e}")
  end

  adapter = config["database"] && config["database"]["adapter"]
  case adapter
  when "mysql2"
    gem = '"mysql2", "~> 0.3.18"'
  when "sqlite3"
    gem = '"sqlite3"'
  when "postgresql"
    gem = '"pg"'
  else
    failure("your itmsweb.yml contains an unknown or missing database adapter '#{adapter}', dependency upgrade must be done manually")
  end

  File.open(gemfile, "a") { |io| io.puts "gem #{gem}" }
end

abort "usage: upgrade CURRENT_INSTALLATION_DIRECTORY" if ARGV.none?

install_root = File.expand_path(ARGV.shift)
failure("cannot find the current installation directory #{install_root}") unless File.directory?(install_root)

not_in_root = "missing %s; upgrade must be run in the upgraded version's root directory"
failure(not_in_root % "bin") unless File.directory?("bin")

install_paths = []
Dir.entries("bin").each do |name|
  next if name == "." || name == ".."
  install_paths << [ File.join("bin", name), File.join(install_root, "bin") ]
end

failure(not_in_root % "bin/*") if install_paths.none?

%w[app api lib models public tasks].each do |target|
  failure(not_in_root % target) unless File.directory?(target)
  install_paths << [target, install_root]
end

# Don't want to overwrite config/itmsweb.yml
%w[apps.rb boot.rb database.rb].each do |target|
  install_paths << [ File.join("config", target), File.join(install_root, "config") ]
end

gemfile = File.join(install_root, "Gemfile.#{RUBY_PLATFORM}")
install_paths << [ "Gemfile", gemfile ]
install_paths << [ "db/migrate", File.join(install_root, "db") ]
install_paths << [ "Rakefile", install_root ]
# Padrino always loads this, v0.2.0 prevents require error
install_paths << [ "spec/spec.rake", File.join(install_root, "spec") ]

install_paths.each do |source, dest|
  puts "Upgrading #{dest} with #{source}"
  FileUtils.cp_r(source, dest)
end

ENV["BUNDLE_GEMFILE"] = gemfile

Dir.chdir(install_root)

puts "Upgrading dependencies..."
upgrade_gemfile(gemfile)

abort "Installation failed" unless system "bundle install --path vendor/bundle --without=test development --binstubs"

# Remove unneeded files created by bundle --binstubs
File.delete(*Dir["bin/*"].reject { |path|
  %w[padrino itmsweb itmsworker].include?(File.basename(path).sub(/\.\w+\Z/, ""))
})

failure("DB upgrade failed") unless system("ruby bin/padrino rake -e production ar:migrate")

puts(<<SUCCESS)
------------------------------

Upgrade successful!
If itmsweb and/or itmsworker are running you must restart them for the upgrade to take effect.

Thanks for using the iTunes Store Transporter: GUI.
http://transportergui.com

------------------------------
SUCCESS
