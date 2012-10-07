class StatusJob < TransporterJob
  def target 
    options[:vendor_id] || super
  end

  protected
  def run
    itms.status(options)
  end
end
