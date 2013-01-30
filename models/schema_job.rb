class SchemaJob < TransporterJob
  protected
  def run
    itms.schema(options)
  end

  def _target 
    options[:version] && options[:type] ? "#{options[:version]}-#{options[:type]}" : super
  end
end
