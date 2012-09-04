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
                                         :type 	     => 2,
                                         :username   => 90,
                                         :shortname  => 91,
                                         :password   => 92)

  def sort_options(job)
    options = job.options.keys.sort_by { |key| JOB_OPTION_ORDER[key] }
    # The path to the :log is used internally, it's not a user-defined option
    options.delete(:log)
    options
  end

  # Some options end with "_id", titleize() removes "_id"
  def optionize(option)
    option = option.to_s
    name = option.titleize

    if option.end_with?("_id")
      name << " ID" 
    elsif option == "failure" || option == "success"
      name = "On #{name}"
    elsif option == "delete"           
      name << " on Success"
    end

    name
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

  def xml_actions(id)
    link_to(content_tag(:i, "", :class => "icon-resize-full")  + "View", url_for(:job_metadata, id, :format => :xml)) + "\n" + 
    link_to(content_tag(:i, "", :class => "icon-download-alt") + "Download", url_for(:job_metadata, id))
  end

  def sort_by(column)
    dir = params[:direction] == "asc" ? "desc" : "asc"
    arr = dir == "asc" ? "&darr;" : "&uarr;" if params[:order] == column
    "#{arr} #{link_to(column.titleize, url(:jobs, params.merge("order" => column, "direction" => dir)))}"    
  end
end
