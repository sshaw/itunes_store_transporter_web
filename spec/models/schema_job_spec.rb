require "spec_helper"
require "shared_examples_for_a_transporter_job"

RSpec.describe SchemaJob, :model do
  subject(:job) { build(:schema_job) }

  it_should_behave_like "a transporter job"

  describe "when executed" do
    it "retrieves a schema" do

      schema = "<x>123</x>"

      itms = stub_itms(job)
      expect(itms).to receive(:schema).with(hash_including(job.options)).and_return(schema)

      job.perform

      expect(job.result).to eq schema
    end
  end
end
