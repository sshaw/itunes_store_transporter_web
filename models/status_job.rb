class StatusJob < TransporterJob
  def success(job)
    super
    update_package
  end

  protected

  def run
    itms.status(options)
  end

  def _target
    options[:vendor_id] || super
  end

  def update_package
    pkg = Package.where(:vendor_id => _target).first
    return unless pkg

    begin
      pkg.update!(:last_status_check => Time.current,
                  :current_status => PackageStatus.new(result[0]).to_s)
    rescue => e
      logger.error("Failed to update package's status check time for vendor_id #{_target}: #{e}")
    end
  end
end
