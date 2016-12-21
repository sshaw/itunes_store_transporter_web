require "itunes/store/transporter/web/command"

RunExecuteHookJob = Struct.new(:job_id) do
  def perform
    job = TransporterJob.find(job_id)
    if job.command
      command = ITunes::Store::Transporter::Web::Command.new(job)
      command.execute(job.execute)
      return
    end

    message = sprintf("command hook failed: no command associated with %s job (#%s)", job.type, job.id)
    logger.error(message)
  rescue => e
    logger.error("command hook failed: #{e}")
  end

  def queue_name
    "hooks".freeze
  end
end
