class SchemaJob < TransporterJob
  def target 
    options[:version] && options[:type] ? "#{options[:version]}-#{options[:type]}" : super
  end

  protected
  def run
    itms.schema(options)
  end
end
