class StatusJob < TransporterJob
  protected
  def run
    itms.status(options)
  end

  def _target 
    options[:vendor_id] || super
  end
end
