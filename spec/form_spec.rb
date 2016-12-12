require "spec_helper"
require "fileutils"

RSpec.describe UploadForm do
  XML_NO_VENDOR_ID =<<-XML.freeze
    <package>
      <video>
        <title>Some title</title>
      </video>
    </package>
  XML

  XML_NO_TITLE =<<-XML.freeze
    <package>
      <video>
        <vendor_id>X123</vendor_id>
      </video>
    </package>
  XML

  context "given a single package" do
    before do
      @pkg = create_package("foo")
      @form = described_class.new(:package => @pkg)
    end

    after  { FileUtils.rm_rf(@pkg) }

    it "requires a metadata.xml file in the package directory" do
      form = described_class.new(:package => "bad.itmsp")
      form.valid?
      expect(form.errors[:base]).to include("No metadata.xml in bad.itmsp")
    end

    it "requires metadata.xml to have a vendor id" do
      create_metadata(@pkg, XML_NO_VENDOR_ID)

      @form.valid?
      expect(@form.errors[:base]).to include("Metadata missing vendor_id in foo.itmsp")
    end

    it "requires metadata.xml to have a title" do
      create_metadata(@pkg, XML_NO_TITLE)

      @form.valid?
      expect(@form.errors[:base]).to include("Metadata missing title in foo.itmsp")
    end

    context "when metadata.xml has the required values" do
      it "does not result in any errors" do
        create_metadata(@pkg)

        @form.valid?
        expect(@form.errors[:base]).to be_empty
      end
    end

    describe "#packages" do
      it "builds a package with the metadata's vendor_id and title" do
        create_metadata(@pkg)
        account = create(:account)

        form = described_class.new(:package => @pkg, :account_id => account.id)
        expect(form.packages.size).to eq 1
        expect(form.packages.first).to be_new_record
        expect(form.packages.first.vendor_id).to eq "X123"
        expect(form.packages.first.title).to eq "Some title"
      end

      it "finds exiting packages with metadata's vendor_id" do
        create_metadata(@pkg)
        account = create(:account)
        create(:package, :vendor_id => "X123")

        form = described_class.new(:package => @pkg, :account_id => account.id)
        expect(form.packages.size).to eq 1
        expect(form.packages.first).to_not be_new_record
        expect(form.packages.first.vendor_id).to eq "X123"
      end
    end
  end

  context "given a batch directory" do
    before do
      @batch = Dir.mktmpdir("itmsweb")
      @pkg1 = create_package("pkg1", @batch)
      @form = described_class.new(:package => @batch, :batch => "1")
    end

    after { FileUtils.rm_rf(@batch) }

    it "requires a metadata.xml file in all package directories" do
      @form.valid?
      expect(@form.errors[:base]).to include("No metadata.xml in pkg1.itmsp")
    end

    it "requires metadata.xml to have a vendor id" do
      create_metadata(@pkg1, XML_NO_VENDOR_ID)

      @form.valid?
      expect(@form.errors[:base]).to include("Metadata missing vendor_id in pkg1.itmsp")
    end

    it "requires metadata.xml to have a title" do
      create_metadata(@pkg1, XML_NO_TITLE)

      @form.valid?
      expect(@form.errors[:base]).to include("Metadata missing title in pkg1.itmsp")
    end

    context "when metadata.xml has the required values" do
      it "does not result in any errors" do
        create_metadata(@pkg1)

        @form.valid?
        expect(@form.errors[:base]).to be_empty
      end
    end
  end
end
