FactoryGirl.define do
  factory :job, :class => TransporterJob do
    account
    options { Hash[:username => account.username, :password => account.password] }
  end

  factory :providers_job, :parent => :job, :class => ProvidersJob

  factory :lookup_job, :parent => :job, :class => LookupJob do
    after :build do |job|
      if !job.options.include?(:apple_id) && !job.options.include?(:vendor_id)
        id = [:vendor_id, :apple_id].sample
        job.options[id] = job.object_id.to_s
      end
    end
  end

  factory :schema_job, :parent => :job, :class => SchemaJob do
    after :build do |job|
      job.options.merge!(:version => "v1.0", :type => "film")
    end
  end

  factory :status_job, :parent => :job, :class => StatusJob do
    after :build do |job|
      job.options[:vendor_id] = job.object_id.to_s
    end
  end

  %w[upload verify].each do |type|
    factory "#{type}_job", :parent => :job, :class => "#{type.titleize}Job" do
      after :build do |job|
        job.options[:package] = File.join(Dir.tmpdir, "X123.itmsp")
      end
    end
  end
end
