module ITunes
  module Store
    module Transporter
      module Web
        module Search
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

              @base_query.where(conditions)
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
            DEFAULT_ORDER = "created_at".freeze
            VALID_COLUMNS = %w[priority target type state account created_at updated_at].freeze

            def initialize(base_query)
              @base_query = base_query
            end

            def build(params)
              column, direction = params[:order].to_s.split(":")

              if column == "account"
                column = "accounts.username"
              # FIXME: we don't want to allow *all* columns
              elsif !VALID_COLUMNS.include?(column)
                column = DEFAULT_ORDER.dup
              end

              column << " " << (direction != "asc" ? "desc" : direction)

              q = @base_query.order(column)
              q = q.joins(:account) if column.start_with?("account")
              q
            end
          end
        end
      end
    end
  end
end
