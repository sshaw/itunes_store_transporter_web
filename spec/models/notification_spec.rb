require "spec_helper"

RSpec.describe Notification do
  # Really just for account_id uniqueness validation
  subject(:notification) { build(:notification, :account => create(:account)) }

  shared_examples_for "an ERB template" do |attribute|
    context "when it contains an invalid variable interpolation" do
      it "adds a validation error" do
        notice = described_class.new(attribute => "<%= foo %>")
        notice.valid?

        expect(notice.errors[attribute]).to include("undefined local variable or method `foo'")
      end
    end

    context "when it contains a syntax error" do
      it "adds a syntax related validation error" do
        notice = described_class.new(attribute => "a\n<%= def %>")
        notice.valid?

        expect(
          notice.errors[attribute].any? { |m| m =~ /line 2, syntax error.+/ }
        ).to be true
      end
    end
  end

  it { is_expected.to belong_to(:account) }

  it { is_expected.to validate_presence_of(:to) }
  it { is_expected.to allow_value("a@b.com\n\nb@c.com\n\n").for(:to) }
  it { is_expected.to allow_value("a@b.com, b@c.com ").for(:to) }
  it { is_expected.to_not allow_value("a@b.com, foo").for(:to).with_message("email invalid 'foo'") }

  it { is_expected.to validate_presence_of(:from) }
  it { is_expected.to allow_value("a@b.com").for(:from) }
  it { is_expected.to_not allow_value("foo").for(:from) }

  it { is_expected.to allow_value("a@b.com").for(:reply_to) }
  it { is_expected.to_not allow_value("foo").for(:reply_to) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:account_id) }
  it { is_expected.to validate_uniqueness_of(:account_id) }

  describe "#recipients" do
    it "splits addresses it #to on a comma" do
      notice = build(:notification, :to => "a@b.com, b@c.com")
      expect(notice.recipients).to eq %w[a@b.com b@c.com]
    end

    it "splits addresses in #to on '\n'" do
      notice = build(:notification, :to => "\na@b.com\n\nb@c.com\n")
      expect(notice.recipients).to eq %w[a@b.com b@c.com]
    end

    it "splits addresses in #to on '\r\n'" do
      notice = build(:notification, :to => "\r\na@b.com\r\n\r\nb@c.com\r\n")
      expect(notice.recipients).to eq %w[a@b.com b@c.com]
    end

    context "when #to is nil" do
      it "returns an empty array" do
        expect(build(:notification, :to => nil).recipients).to eq []
      end
    end
  end

  describe "#message" do
    it_should_behave_like "an ERB template", :message
  end

  describe "#subject" do
    it_should_behave_like "an ERB template", :subject
  end
end
