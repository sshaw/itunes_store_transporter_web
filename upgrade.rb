require "fileutils"

def failure(msg)
  abort "upgrade failed: #{msg}"
end

abort "usage: upgrade CURRENT_INSTALLATION_DIRECTORY" if ARGV.none?

install_root = ARGV.shift
failure("cannot find the current installation directory #{install_root}") unless File.directory?(install_root)

not_in_root = "missing %s; upgrade must be run in the upgraded version's root directory"
failure(not_in_root % "bin") unless File.directory?("bin")

install_paths = []
Dir.entries("bin").each do |name|
  # Explicitly skip padrino, in case the user ran setup.rb in the upgrade version's directory
  next if name == "padrino" || name == "." || name == ".."
  install_paths << [ File.join("bin", name), File.join(install_root, "bin") ]
end

failure(not_in_root % "bin/*") if install_paths.none?

%w[app lib models public].each do |target|
  failure(not_in_root % target) unless File.directory?(target)
  install_paths << [target, install_root]
end

install_paths << [ "db/migrate", File.join(install_root, "db") ]

install_paths.each do |source, dest|
  puts "Upgrading #{dest} with #{source}"
  FileUtils.cp_r(source, dest)
end

Dir.chdir(install_root)

ENV["PADRINO_ENV"] = "production"
failure("failed to run DB migrations, see above error") unless system("bin/padrino rake ar:migrate")

puts(<<SUCCESS)
------------------------------

Upgrade successful!
If itmsweb and/or itmsworker are running you must restart them for the upgrade to take effect.

Thanks for using the Transporter GUI.
http://transportergui.com

------------------------------
SUCCESS
