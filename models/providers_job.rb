class ProvidersJob < TransporterJob
  protected
  def run
    itms.providers(options)
  end
end
