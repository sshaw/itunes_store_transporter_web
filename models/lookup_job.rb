class LookupJob < TransporterJob
  protected
  def run
    itms.lookup(options)
  end

  def _target
    options[:vendor_id] || options[:apple_id] || super
  end
end
