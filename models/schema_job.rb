class SchemaJob < TransporterJob
  def target 
    "#{options[:version]}-#{options[:type]}"
  end

  protected
  def run
    itms.schema(options)
  end
end
