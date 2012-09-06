class LookupJob < TransporterJob
  def target
    options[:vendor_id] || options[:apple_id] || super
  end

  protected
  def run
    itms.lookup(options)
  end
end
