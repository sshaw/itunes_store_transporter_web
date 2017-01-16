require "spec_helper"
require "itunes/store/transporter/web/package_status"

RSpec.describe ITunes::Store::Transporter::Web::PackageStatus do
  context "when :not_on_store is not empty and a :video_components status is not 'Approved'" do
    it "returns 'Not on Store'" do
      @status = {
        :apple_id=>"X",
        :vendor_id=>"Y",
        :content_status=>
        {:store_status=>
         {:not_on_store=>["US"], :on_store=>[], :ready_for_store=>[]},
         :video_components=> [
           :name=>"Audio",
           :locale=>"en-US",
           :status=>"Foo Status"]}}

      expect(described_class.new(@status).to_s).to eq "Not on Store"
    end
  end

  context "when :not_on_store is empty and a :video_components status is nil" do
    it "returns 'Not on Store'" do
      @status = {
        :apple_id=>"X",
        :vendor_id=>"Y",
        :content_status=>
        {:store_status=>
         {:not_on_store=>[], :on_store=>[], :ready_for_store=>[]},
         :video_components=> [
           :name => "Video",
           :status => nil,
           :locale => "en-US"]}}

      expect(described_class.new(@status).to_s).to_not eq "Not on Store"
    end
  end
end
