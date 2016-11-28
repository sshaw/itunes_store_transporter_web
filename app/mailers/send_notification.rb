class SendNotification
  def send(job_id)
    job = TransporterJob.includes(:account => :notification).find(job_id)
    raise ArgumentError, error_message(job) if job.account.notification.nil?
    ItunesStoreTransporterWeb.deliver(:notifications, :job_completed, job)
  end

  private

  def error_message(job)
    sprintf("Cannot send notification for '%s' %s job (#%d): '%s' account does not have a notification",
            job.target,
            job.type,
            job.id,
            job.account.username)
  end
end
