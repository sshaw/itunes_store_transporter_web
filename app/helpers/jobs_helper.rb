ItunesStoreTransporterWeb.helpers do
  JOB_OPTION_ORDER = Hash.new(100).merge(# Upload
                                         :package    => 1,
                                         :transport  => 2,
                                         :rate       => 3,
                                         :success    => 4,
                                         :failure    => 4,
                                         :delete     => 5,
                                         # Verify
                                         :verify_assets => 2,
                                         # Lookup
                                         :vendor_id  => 1,
                                         :apple_id   => 1,
                                         # Schema
                                         :version    => 1,
                                         :type       => 2,
                                         # ====>
                                         :username   => 90,
                                         :shortname  => 91,
                                         :password   => 92)

  def sort_options(job)
    options = job.options.keys.sort_by { |key| JOB_OPTION_ORDER[key] }
    # The path to the :log is used internally, it's not a user-defined option
    options.delete(:log)
    options
  end

  def target(job)
    job.target.present? ? link_to(job.target, url(:job, :id => job.id)) : "&mdash;"
  end

  def format_option_name(option)
    option = option.to_s
    name = option.titleize

    # Some options end with "_id", titleize() removes "_id"
    if option.end_with?("_id")
      name << " ID"
    elsif option == "username"
      name = "Account"
    elsif option == "failure" || option == "success"
      name = "On #{name}"
    elsif option == "delete"
      name << " on Success"
    end

    name
  end

  def format_option_value(name, value)
    if name == :rate && value.present?
      number_with_delimiter(value) << " Kbps"
    elsif name == :password
      "*" * 8
    elsif value.present? || value == false
      h value
    else
      "&mdash;"
    end
  end

  def account_options(accounts)
    options = []

    Array(accounts).sort_by { |u| u.display_name }.group_by(&:display_name).each do |_, users|
      users.each do |u|
        options << [
          users.one? ? u.display_name : sprintf("%s (%s)", u.display_name, u.shortname),
          u.id
        ]
      end
    end

    options
  end

  def current_search_query(accounts)
    terms = []

    [:priority, :state, :target, :type].each do |name|
      next if params[name].blank?
      term = case name
        when :type
          params[name].sub(/Job$/, "")
        when :target
          %Q("#{params[name]}")
        else
          params[name].capitalize
        end
      terms << "#{name} #{term}"
    end

    if params[:account_id].present?
      id = params[:account_id].to_i
      if account = accounts.find { |a| a.id == id }
        terms << "account %s" % %Q("#{account.display_name}")
      end
    end

    updated = [:_updated_at_from, :_updated_at_to].inject([]) { |q, key| q << params[key] if params[key].present?; q }
    if updated.any?
      if updated.size > 1
        terms << "updated #{updated[0]} to #{updated[1]}"
      else
        terms << "updated #{updated[0]}"
      end
    end

    truncate terms.join(" "), :length => 75
  end

  def render_job_result(job)
    render_partial "jobs/results/#{job.type.downcase}", :locals => { :job => job }
  end

  def highlite(txt, format)
    CodeRay.scan(txt, format).div #(:line_numbers => :table)
  end

  def state_label(state)
    content_tag :span, state.to_s.titleize, :class => "job-state label label-#{state}"
  end

  def link_to_download(url)
    link_to content_tag(:i, "", :class => "icon-download-alt") << "Download", url
  end

  def link_to_view(url)
    link_to content_tag(:i, "", :class => "icon-resize-full")  << "View", url
 end

  def job_state_options
    TransporterJob::STATES.map { |state| [ state.to_s.capitalize, state ] }
  end

  def job_type_options
    %w[LookupJob ProvidersJob SchemaJob StatusJob UploadJob VerifyJob VersionJob].map { |type| [ type.sub(/Job$/, ""), type ] }
  end

  def sort_by(column)
    dir = params[:direction] == "asc" ? "desc" : "asc"
    arr = dir == "asc" ? "&darr;" : "&uarr;" if params[:order] == column
    link_to(column.titleize, current_path(params.merge("order" => column, "direction" => dir))) << " #{arr}"
  end
end
