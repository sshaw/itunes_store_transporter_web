require "template"

ItunesStoreTransporterWeb.mailer :notifications do
  email :job_completed do |job|
    t = Template.new(job)
    notice = job.account.notification

    from notice.from
    to   notice.recipients
    subject  t.render(notice.subject)
    body     t.render(notice.message)
    reply_to notice.reply_to if notice.reply_to

    config = TransporterConfig.first_or_initialize

    settings = {}
    settings[:address] = config.smtp_host if config.smtp_host
    settings[:port] = config.smtp_port if config.smtp_port
    via :smtp, settings if settings.any?
  end
end
