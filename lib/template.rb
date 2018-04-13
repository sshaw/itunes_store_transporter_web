require "tilt"

class Template
  RenderError = Class.new(StandardError)

  def initialize(job)
    @params = {
      :job_id => job.id,
      :job_package_path => job.options[:package],
      :job_state => job.state.to_s,
      :job_created => job.created_at,
      :job_completed => job.updated_at,
      :job_type => job.type.downcase,
      :job_target => job.target,
      :account_itc_provider => job.options[:itc_provider],
      :account_username => job.options[:username],
      :account_shortname => job.options[:shortname],
      :email_to => nil,
      :email_from => nil,
      :email_reply_to => nil
    }

    if job.account.try(:notification)
      notice = job.account.notification
      @params.merge!(
        :email_to => notice.recipients,
        :email_from => notice.from,
        :email_reply_to => notice.reply_to
      )
    end
  end

  def render(template)
    @template = Tilt::ERBTemplate.new { template }
    @template.render(nil, @params)
  rescue NameError => e
    # Remove class name from message
    raise RenderError, e.message.sub(/\s+for\s+.+/ms, ""), e.backtrace
  rescue SyntaxError => e
    # Extract line number and remove the _erbout stuff
    if e.message =~ %r{\(__TEMPLATE__\):(\d+):\s*(.+)} # everything to "\n"
      raise RenderError, "line #$1, #$2", e.backtrace
    else
      raise RenderError, e.message, e.backtrace
    end
  rescue => e
    raise RenderError, "failed to render template: #{e}", e.backtrace
  end
end
