require "itunes/store/transporter/web/search"

module ITunes
  module Store
    module Transporter
      module Web
        App.helpers do
          def status_label(status)
            return unless status.present?
            content_tag :span, status, :class => "label label-status-#{status.parameterize}"
          end

          def status_options
            (Search::Package::Where::KNOWN_STATUSES + [Search::Package::Where::STATUS_OTHER]).sort
          end
        end
      end
    end
  end
end
