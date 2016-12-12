module Helpers
  METADATA =<<-XML.freeze
    <package>
      <video>
        <title>Some title</title>
        <vendor_id>X123</vendor_id>
      </video>
    </package>
  XML

  def create_package(name = "X#{Time.now.to_i}", root = Dir.tmpdir)
    path = File.join(root, "#{name}.itmsp")
    Dir.mkdir(path)
    path
  end

  def create_metadata(pkg, xml = METADATA)
    File.open("#{pkg}/metadata.xml", "w") { |io| io.puts xml }
  end

  def stub_itms(job)
    transporter = double()
    allow(job).to receive(:itms) { transporter }
    transporter
  end
end
