module ITunes
  module Store
    module Transporter
      module Web
        HELP_PATH = "/docs/help.html".freeze

        App.helpers do
          def alert(message, type=:error)
            content_tag :div, :class => "alert alert-#{type}" do
              link_to("&times;".html_safe, "#", :class => "close", :data => { :dismiss => "alert" }) << message
            end
          end

          def flash_messages
            [:success, :info, :error].inject("") do |html, message|
              if !flash[message].blank?
	        html << alert(flash[message], message)
              end
              html
            end.html_safe
          end

          def help_path(anchor = nil)
            anchor ? sprintf("%s#%s", HELP_PATH, anchor) : HELP_PATH
          end
        end
      end
    end
  end
end
