require "date"

Gem::Specification.new do |s|
  s.name        = "itunes_store_transporter_web_worker"
  s.version     = "0.0.1"
  s.date        = Date.today
  s.summary     = "Worker process for the iTMSTransporter GUI's job queue"
  s.description =<<-DESC
    Worker process for the iTMSTransporter GUI's job queue
  DESC
  s.authors     = ["Skye Shaw"]
  s.email       = "skye.shaw@gmail.com"
  s.executables  << "itmsweb_worker"
  #s.extra_rdoc_files = %w[README.rdoc]
  s.files       = Dir["lib/**/*.rb"] + s.extra_rdoc_files
  s.homepage    = "http://github.com/sshaw/itunes_store_transporter_web"
  s.license     = "MIT"
  s.add_dependency "activerecord", "~> 3.0"
  s.add_dependency "activesupport", "~> 3.0"
  s.add_dependency "daemons", "~> 1.1.8", "< 2"
  s.add_dependency "delayed_job_active_record", "~> 0.3.2"
end
