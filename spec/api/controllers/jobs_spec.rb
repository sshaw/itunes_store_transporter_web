require "spec_helper"
require "json"

RSpec.describe "/api" do
  before :all do
    app ITunes::Store::Transporter::Web::API
    header "content-type", "application/json"
  end

  before { @account = create(:account) }

  context "given a request for an unknown endpoint" do
    it "returns a 404" do
      get "foo_bar"

      expect(last_response.status).to eq 404
      expect(last_response.headers["Content-Type"]).to eq "application/json"
      expect(last_response.body).to eq({ :error => "Not found" }.to_json)
    end
  end

  context "given a request with invalid JSON" do
    it "returns a 400" do
      post "schema", "{"

      expect(last_response.status).to eq 400
      expect(last_response.headers["Content-Type"]).to eq "application/json"

      json = JSON.parse(last_response.body)
      expect(json["error"]).to match "parse error"
    end
  end

  describe "GET to jobs/:id" do
    it "returns the job for the given id" do
      job = create(:job)
      get app.url(:jobs, :id => job.id)

      expect(last_response.status).to eq 200
      expect(last_response.body).to eq job.to_json
    end

    context "when the id does not exist" do
      it "returns a 404" do
        get app.url(:jobs, :id => 9999)

        expect(last_response.status).to eq 404
        expect(last_response.headers["Content-Type"]).to eq "application/json"
        expect(last_response.body).to match(/couldn't find/i)
      end
    end
  end

  describe "GET to search" do
    before do
      create(:status_job)
      create(:upload_job)
    end

    context "given criteria with no results" do
      it "does not return any jobs" do
        results = {
          "jobs" => [],
          "page" => {
            "number" => 1,
            "count" => 1,
            "size" => 10
          }
        }

        get "jobs/search", { :type => "verify", :page => 1, :per_page => 10 }

        expect(last_response.status).to eq 200
        expect(last_response.headers["Content-Type"]).to eq "application/json"
        expect(JSON.parse(last_response.body)).to eq results
      end
    end

    context "given a job type" do
      it "returns jobs of the given type" do
        get "jobs/search", { :type => "upload", :page => 1, :per_page => 10 }

        expect(last_response.status).to eq 200
        expect(last_response.headers["Content-Type"]).to eq "application/json"

        json = JSON.parse(last_response.body)
        expect(json["page"]).to eq "number" => 1, "count" => 1, "size" => 10
        expect(json["jobs"].size).to eq 1
        expect(json["jobs"].first).to include("type" => "upload")
      end
    end
  end

  describe "POST to upload" do
    it "creates an upload job" do
      params = {
        :account_id => @account.id,
        :package => "/a/dir.itmsp",
        :batch => false,
        :success => "good",
        :failure => "bad",
        :priority => "high",
        :delete => true,
        :transport => "Aspera"
      }

      post "upload", params.to_json

      expect(last_response.status).to eq 201
      expect(last_response.headers["Content-Type"]).to eq "application/json"
      expect(last_response.body).to eq UploadJob.last.to_json
    end

    context "when required values are missing" do
      it "returns an error" do
        error = {
          :account_id => ["can't be blank"],
          :package => ["can't be blank"]
        }.to_json

        post "upload", "{}"

        expect(last_response.status).to eq 422
        expect(last_response.headers["Content-Type"]).to eq "application/json"
        expect(last_response.body).to eq error
      end
    end
  end
end
