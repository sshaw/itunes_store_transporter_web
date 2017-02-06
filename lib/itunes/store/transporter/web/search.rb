require "itunes/store/transporter/web/package_status"

module ITunes
  module Store
    module Transporter
      module Web
        module Search
          module Util
            private

            def column_order(column, direction)
              sprintf "%s %s", column, (direction != "asc" ? "desc" : direction)
            end
          end

          module Package
            class Where
              STATUS_OTHER = "Other".freeze
              STATUS_NE_ON_STORE = "!= On Store".freeze
              KNOWN_STATUSES = [
                PackageStatus::NOT_ON_STORE,
                PackageStatus::IN_REVIEW,
                PackageStatus::READY_FOR_STORE,
                PackageStatus::ON_STORE
              ].freeze

              def initialize(base_query)
                @base_query = base_query
              end

              def build(params)
                q = @base_query

                if params[:current_status].present?
                  q = case params[:current_status]
                  when STATUS_OTHER
                    q.where("current_status not in (?)", KNOWN_STATUSES)
                  when STATUS_NE_ON_STORE
                    q.where("current_status != ?", PackageStatus::ON_STORE)
                  else
                    q.where(:current_status => params[:current_status])
                  end
                end

                q.includes(:account)
              end
            end

            class Order
              include Util

              DEFAULT_ORDER = "updated_at".freeze
              VALID_COLUMNS = %w[account created_at current_status last_upload last_status_check title vendor_id].freeze

              def initialize(base_query)
                @base_query = base_query
              end

              def build(params)
                column, direction = params[:order].to_s.split(":")

                if column == "account"
                  column = "accounts.shortname"
                elsif !VALID_COLUMNS.include?(column)
                  column = DEFAULT_ORDER
                end

                q = @base_query.order(column_order(column, direction))
                q = q.joins(:account) if column.start_with?("account")
                q
              end
            end
          end

          module Jobs
            class Where
              def initialize(base_query)
                @base_query = base_query
              end

              def build(params)
                conditions = {}

                [:priority, :target, :state, :account_id].each do |k|
                  conditions[k] = params[k] if params[k].present?
                end

                if params[:type].present?
                  conditions[:type] = sprintf("%sJob", params[:type].capitalize)
                end

                if params[:updated_at_from].present?
                  conditions[:updated_at] = updated_at_query(*params.values_at(:updated_at_from, :updated_at_to))
                end

                @base_query.includes(:account).where(conditions)
              end

              private

              def updated_at_query(from, to = nil)
                dates = []

                begin
                  dates << from.to_time(:local)
                  dates << (to.present? ? to.to_time(:local).end_of_day : dates[0].end_of_day)
                rescue ArgumentError
                  # Ignore invalid dates
                  return dates

                end

                Range.new(*dates)
              end
            end

            class Order
              include Util

              DEFAULT_ORDER = "created_at".freeze
              VALID_COLUMNS = %w[priority target type state account created_at updated_at].freeze

              def initialize(base_query)
                @base_query = base_query
              end

              def build(params)
                column, direction = params[:order].to_s.split(":")

                if column == "account"
                  column = "accounts.username"
                elsif !VALID_COLUMNS.include?(column)
                  column = DEFAULT_ORDER
                end

                q = @base_query.order(column_order(column, direction))
                q = q.joins(:account) if column.start_with?("account")
                q
              end
            end
          end
        end
      end
    end
  end
end
