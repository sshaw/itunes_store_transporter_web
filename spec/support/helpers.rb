module Helpers
  def create_package(name = "X#{Time.now.to_i}")
    path = File.join(Dir.tmpdir, "#{name}.itmsp")
    Dir.mkdir(path)
    path
  end

  def stub_itms(job)
    transporter = double()
    allow(job).to receive(:itms) { transporter }
    transporter
  end
end
