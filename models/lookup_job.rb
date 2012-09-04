class LookupJob < TransporterJob
  def target
    options[:vendor_id] || options[:apple_id]
  end

  protected
  def run
    itms.lookup(options)
  end
end
