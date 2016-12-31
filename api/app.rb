require "rack"

module ITunes
  module Store
    module Transporter
      module Web
        class API < Padrino::Application
          use ConnectionPoolManagement

          include PageNumber

          set :show_exceptions, false

          before { content_type "application/json" }

          not_found do
            { :error => "Not found" }.to_json
          end

          error ActiveRecord::RecordNotFound do
            halt 404, error_response
          end

          error JSON::ParserError do
            halt 400, error_response("JSON parse error")
          end

          error { error_response }

          protected

          def default_per_page
            10
          end

          private

          def error_response(prefix = nil)
            message = env["sinatra.error"].message
            message.prepend("#{prefix}: ") if prefix

            { :error => message }.to_json
          end
        end
      end
    end
  end
end
