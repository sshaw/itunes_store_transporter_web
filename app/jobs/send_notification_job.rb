SendNotificationJob = Struct.new(:job_id) do
  def perform
    SendNotification.new.send(job_id)
  end

  def queue_name
    "notifications".freeze
  end
end
