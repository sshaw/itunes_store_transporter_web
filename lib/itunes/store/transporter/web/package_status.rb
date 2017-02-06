module ITunes
  module Store
    module Transporter
      module Web
        class PackageStatus
          NOT_ON_STORE = "Not on Store".freeze
          IN_REVIEW = "In Review".freeze
          READY_FOR_STORE = "Ready for Store".freeze
          ON_STORE = "On Store".freeze

          APPROVED = "Approved".freeze
          REJECTED = "Rejected".freeze

          def initialize(status)
            @status = status || {}
          end

          def to_s
            case
            when not_on_store?
              NOT_ON_STORE.dup
            when in_review?
              IN_REVIEW.dup
            when ready_for_store?
              READY_FOR_STORE.dup
            when on_store?
              ON_STORE.dup
            else
              ""
            end
          end

          alias :inspect :to_s

          private

          def content_status
            @content_status ||= @status[:content_status] || {}
          end

          def video_components
            @video_components ||= (content_status[:video_components] || []).reject { |v| v[:status].nil? }
          end

          def store_status
            return @store_status if defined?(@store_status)
            @store_status = content_status[:store_status] || {}
            @store_status.default = []
            @store_status
          end

          def not_on_store?
            store_status[:not_on_store].any? ||
              video_components.any? { |vc| vc[:status] == REJECTED }
          end

          def in_review?
            video_components.any? { |vc| vc[:status] == IN_REVIEW }
          end

          def ready_for_store?
            store_status[:ready_for_store].any? &&
              video_components.any? &&
              video_components.all? { |vc| vc[:status] == APPROVED }
          end

          def on_store?
            store_status[:on_store].any? &&
              video_components.any? &&
              video_components.all? { |vc| vc[:status] == APPROVED }
          end
        end
      end
    end
  end
end
