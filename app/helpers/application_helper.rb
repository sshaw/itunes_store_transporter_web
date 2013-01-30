ItunesStoreTransporterWeb.helpers do
  def title(t = nil)
    @title ||= "iTunes Store Transporter"
    return @title unless t
    @title = "#{t} - #{@title}" if t
    @title
  end

  def alert(message, type=:error)
    content_tag(:div, link_to("&times;", "#", :class => "close", :data => { :dismiss => "alert" }) << message, :class => "alert alert-#{type}")
  end

  def flash_messages
    [:success, :info, :error].inject("") do |html, message|
      if !flash[message].blank?
	html << alert(flash[message], message)
      end
      html
    end
  end

  def show_auth_fields?(form)
    options = form.marshal_dump[:options]
    [:username, :password, :shortname].any? { |f| form.errors[f].any? || options[f].blank? }
  end
end
