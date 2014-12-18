ItunesStoreTransporterWeb.helpers do
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
end
