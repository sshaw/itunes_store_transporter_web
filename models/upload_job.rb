require "delayed_job"

class UploadJob < TransporterJob
  serialize :vendor_ids

  def after(job)
    Delayed::Job.enqueue(RunExecuteHookJob.new(id)) if execute.present?

    return if skip_notification?
    Delayed::Job.enqueue(SendNotificationJob.new(id))
  end

  def success(job)
    super
    update_package
  end

  def as_json(options = nil)
    json = super
    json.delete("vendor_ids")
    json
  end

  protected

  def typecast_options
    options[:rate]   = options[:rate].to_i if options[:rate] =~ /\A\d+\z/
    options[:delete] = to_bool(options[:delete])
    options[:batch]  = to_bool(options[:batch])
    true
  end

  def run
    optz = options.dup
    package = optz.delete(:package)
    itms.upload(package, optz)
  end

  def _target
     options[:package] ? File.basename(options[:package]) : super
  end

  private

  def skip_notification?
    disable_notification || account.disable_notification || account.notification.nil?
  end

  def update_package
    Package.where(:vendor_id => vendor_ids).update_all(:last_upload => Time.current)
    Package.where(:vendor_id => vendor_ids, :current_status => nil).
      update_all(:current_status => state.to_s.titleize)
  end
end
