require "spec_helper"
require "itunes/store/transporter/web/package_status"

RSpec.describe ITunes::Store::Transporter::Web::PackageStatus do
  context "when :not_on_store contains a country" do
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

  context "when :not_on_store is empty and a :video_component is 'Rejected'" do
    it "returns 'Not on Store'" do
      @status = {
        :apple_id=>"X",
        :vendor_id=>"Y",
        :content_status=>
        {:store_status=>
         {:not_on_store=>[], :on_store=>[], :ready_for_store=>[]},
         :video_components=> [
           {:name=>"Audio",
            :locale=>"en-US",
            :status=>nil},
           {:name=>"Audio",
            :locale=>"en-US",
            :status=>"Rejected"}
         ]}}

      expect(described_class.new(@status).to_s).to eq "Not on Store"
    end
  end

  context "when all :video_components are 'In Review'" do
    it "returns 'In Review'" do
      @status = {
        :apple_id=>"X",
        :vendor_id=>"Y",
        :content_status=>
        {:store_status=>
         {:not_on_store=>[], :on_store=>[], :ready_for_store=>[]},
         :video_components=> [
           {:name=>"Audio",
            :locale=>"en-US",
            :status=>"In Review"}
         ]}}

      expect(described_class.new(@status).to_s).to eq "In Review"
    end
  end

  context "when only one :video_component is 'In Review'" do
    it "returns 'In Review'" do
      @status = {
        :apple_id=>"X",
        :vendor_id=>"Y",
        :content_status=>
        {:store_status=>
         {:not_on_store=>[], :on_store=>[], :ready_for_store=>[]},
         :video_components=> [
           {:name=>"Audio",
            :locale=>"en-US",
            :status=>"In Review"},
           {:name=>"Audio",
            :locale=>"en-US",
            :status=>"Ready"},
           {:name=>"Video",
            :locale=>"en-US",
            :status=>nil}
         ]}}

      expect(described_class.new(@status).to_s).to eq "In Review"
    end
  end

  context "when :ready_for_store contains a country and all components are 'Approved'" do
    it "returns 'Ready for Store'" do
      @status = {
        :apple_id=>"X",
        :vendor_id=>"Y",
        :content_status=>
        {:store_status=>
         {:not_on_store=>[], :on_store=>[], :ready_for_store=>["US"]},
         :video_components=> [
           {:name=>"Audio",
            :locale=>"en-US",
            :status=>"Approved"},
         ]}}

      expect(described_class.new(@status).to_s).to eq "Ready for Store"
    end
  end

  context "when :on_store contains a country and all components are 'Approved'" do
    it "returns 'On Store'" do
      @status = {
        :apple_id=>"X",
        :vendor_id=>"Y",
        :content_status=>
        {:store_status=>
         {:not_on_store=>[], :on_store=>["US"], :ready_for_store=>[]},
         :video_components=> [
           {:name=>"Audio",
            :locale=>"en-US",
            :status=>"Approved"},
           {:name=>"Audio",
            :locale=>"en-US",
            :status=>nil},
         ]}}

      expect(described_class.new(@status).to_s).to eq "On Store"
    end
  end
end
