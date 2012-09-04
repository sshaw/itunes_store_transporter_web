class VersionJob < TransporterJob
  protected
  def run
    itms.version
  end
end
