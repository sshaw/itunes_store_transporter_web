class StatusJob < TransporterJob
  def target 
    options[:vendor_id]
  end

  protected
  def run
    itms.status(options)
  end
end
