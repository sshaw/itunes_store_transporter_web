require "template"
require "valid_email"

class Notification < ActiveRecord::Base
  belongs_to :account

  # Just use ID for form validation purposes :'(
  validates :account_id, :presence => true
  validates :name, :presence => true
  validates :to, :presence => true
  validates :from, :email => true
  validates :reply_to, :email => { :allow_blank => true }
  validates :subject, :presence => true
  validates :account_id, :uniqueness => true

  validate :validate_message, :validate_subject, :validate_emails

  def recipients
    to.present? ? to.split(/\r?\n|,/).map(&:strip).reject(&:empty?) : []
  end

  private

  def validate_emails
    invalid = recipients.find { |email| !ValidateEmail.valid?(email) }
    errors.add(:to, "email invalid '#{invalid}'") if invalid
  end

  def validate_template(name)
    return unless self[name]

    begin
      t = Template.new(UploadJob.new)
      t.render(self[name])
    rescue Template::RenderError => e
      errors.add(name, e.message)
    end
  end

  def validate_subject
    validate_template(:subject)
  end

  def validate_message
    validate_template(:message)
  end
end
