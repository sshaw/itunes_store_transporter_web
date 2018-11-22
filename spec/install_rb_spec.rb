require "spec_helper"

require "yaml"
require "fileutils"

RSpec.describe "Running the install script" do
  before :all do
    @tmpdir = Dir.mktmpdir
    # Don't cp Padrino.root's name to @tmpdir
    FileUtils.cp_r(Padrino.root + "/.", @tmpdir)
    Dir.chdir @tmpdir
  end

  after :all do
    FileUtils.rm_rf(@tmpdir)
  end

  context "given command-line arguments" do
    before :all do
      Bundler.with_clean_env do
        ruby = RbConfig::CONFIG["RUBY_INSTALL_NAME"]
        system "#{ruby} install.rb --db-user=sshaw --db-password=blah --db-host=example.com --db-driver=sqlite"
      end

      @resulting_config = YAML.load_file("#@tmpdir/config/itmsweb.yml")
      @resulting_config = @resulting_config["database"] || {}
    end

    it "writes the right db name to the config file" do
      expect(@resulting_config["name"]).to match(%r{/itmsweb.sqlite3\z})
    end

    it "allows one to set the db driver" do
      expect(@resulting_config["adapter"]).to eq "sqlite3"
    end

    it "allows one to set the db user" do
      expect(@resulting_config["username"]).to eq "sshaw"
    end

    it "allows one to set the db password" do
      expect(@resulting_config["password"]).to eq "blah"
    end

    it "allows one to set the db host" do
      expect(@resulting_config["host"]).to eq "example.com"
    end
  end
end
