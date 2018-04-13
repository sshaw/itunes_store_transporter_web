module ITunes
  module Store
    module Transporter
      module Web
        class Command
          NonZeroExitError = Class.new(StandardError)

          def initialize(job)
            @env = {
              "ITMS_JOB_ID" => job.id.to_s,
              "ITMS_JOB_PACKAGE_PATH" => job.options[:package],
              "ITMS_JOB_STATE" => job.state.to_s,
              "ITMS_JOB_CREATED" => job.created_at.to_s,
              "ITMS_JOB_COMPLETED" => job.updated_at.to_s,
              "ITMS_JOB_TYPE" => job.type.downcase,
              "ITMS_JOB_TARGET" => job.target,
              "ITMS_ACCOUNT_ITC_PROVIDER" => job.options[:itc_provider],
              "ITMS_ACCOUNT_USERNAME" => job.options[:username],
              "ITMS_ACCOUNT_SHORTNAME" => job.options[:shortname]
            }
          end

          def execute(cmd)
            @env.each { |k, v| ENV[k] = v }

            out = `#{cmd} 2>&1`
            unless $?.success?
              raise NonZeroExitError, "command `#{cmd}' exited non-zero (#{$?.exitstatus}): #{out}"
            end

            out
          ensure
            @env.each { |k, _| ENV.delete(k) }
          end
        end
      end
    end
  end
end
