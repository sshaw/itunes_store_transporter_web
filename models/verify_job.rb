class VerifyJob < TransporterJob
  protected

  def typecast_options
    options[:batch] = to_bool(options[:batch])
    options[:verify_assets] = to_bool(options[:verify_assets])
    # If the last expressions returns false save is canceled
    true
  end

  def run
    optz = options.dup
    package = optz.delete(:package)
    itms.verify(package, optz)
  end

  def _target
    options[:package] ? File.basename(options[:package]) : super
  end
end
