require "itunes/store/transporter/web/package_status"

class StatusCheckJob
  include ITunes::Store::Transporter::Web

  def perform
    Package.pending_uploads.includes(:account).find_in_batches(:batch_size => 30) do |packages|
      packages.group_by(&:account).each do |account, batch|
        batch = batch.index_by(&:vendor_id)
        statuses = itms.status(:vendor_id => batch.keys,
                               :username => account.username,
                               :password => account.password,
                               :shortname => account.shortname)

        statuses.each { |status| update_status(batch, status) }
      end
    end
  rescue => e
    logger.error("status check failed: #{e}\n#{e.backtrace}")
  end

  private

  def itms
    ITunes::Store::Transporter.new(:path => TransporterConfig.first_or_initialize.path,
				   :print_stdout => true,
				   :print_stderr => true)
  end

  def update_status(batch, status)
    id = status[:vendor_id]
    unless id
      logger.warn("itms status returned a record without a vendor_id: #{status.inspect}")
      return
    end

    pkg = batch[id]
    pkg.current_status = PackageStatus.new(status).to_s
    pkg.last_status_check = Time.current
    unless pkg.valid?
      logger.error("failed to update status for #{pkg} (##{pkg.id}): #{pkg.errors.full_messages.to_sentence}")
      return
    end

    pkg.save
  end
end
