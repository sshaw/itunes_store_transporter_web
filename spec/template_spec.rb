require "spec_helper"
require "template"

RSpec.describe Template do
  describe "#render" do
    before :all do
      notice = build(:notification, :to => "a@b.com, b@c.com", :from => "a@b.com", :reply_to => "foo@a.com")
      account = create(:account, :username => "sshaw", :shortname => "fofinho", :itc_provider => "blah", :notification => notice)
      @job = create(:upload_job, :options => { :package => "/a/b.itmsp" }, :account => account)
      @template = Template.new(@job)
    end

    context "when the template contains an unknown variable" do
      it "raises a TemplateError" do
        expect { @template.render("<%= big_thangz %>") }.to raise_error(Template::RenderError, /big_thangz/i)
      end
    end

    context "when the template raises an error" do
      it "raises a TemplateError" do
        expect { @template.render("<%= 1/0 %>") }.to raise_error(Template::RenderError, /failed to render/i)
      end
    end

    describe "job variables" do
      it "interpolates 'job_id'" do
        expect(@template.render("<%= job_id %>")).to eq @job.id.to_s
      end

      it "interpolates 'job_type'" do
        expect(@template.render("<%= job_type %>")).to eq "upload"
      end

      it "interpolates 'job_target'" do
        expect(@template.render("<%= job_target %>")).to eq "b.itmsp"
      end

      it "interpolates 'job_package_path'" do
        expect(@template.render("<%= job_package_path %>")).to eq "/a/b.itmsp"
      end

      it "interpolates 'job_state'" do
        expect(@template.render("<%= job_state %>")).to eq "queued"
      end

      it "interpolates 'job_created'" do
        expect(@template.render("<%= job_created %>")).to eq @job.created_at.to_s
      end

      it "interpolates 'job_completed'" do
        expect(@template.render("<%= job_completed %>")).to eq @job.updated_at.to_s
      end
    end

    describe "account variables" do
      it "interpolates 'account_username'" do
        expect(@template.render("<%= account_username %>")).to eq "sshaw"
      end

      it "interpolates 'account_shortname'" do
        expect(@template.render("<%= account_shortname %>")).to eq "fofinho"
      end

      it "interpolates 'account_itc_provider'" do
        expect(@template.render("<%= account_itc_provider %>")).to eq "blah"
      end
    end

    describe "message variables" do
      it "interpolates 'email_to'" do
        expect(@template.render("<%= email_to %>")).to eq %w[a@b.com b@c.com].to_s
      end

      it "interpolates 'email_from'" do
        expect(@template.render("<%= email_from %>")).to eq "a@b.com"
      end

      it "interpolates 'email_reply_to'" do
        expect(@template.render("<%= email_reply_to %>")).to eq "foo@a.com"
      end
    end
  end
end
