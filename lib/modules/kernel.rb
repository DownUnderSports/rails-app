module Kernel
  private
    def local_port
      ENV['LOCAL_PORT'] || '3100'
    end

    def local_domain
      Rails.env.development? ? "localhost:#{local_port}" : "downundersports.com"
    end

    def local_protocol
      Rails.env.development? ? "http" : "https"
    end

    def local_host
      "#{local_protocol}://www.#{local_domain}"
    end

    def auto_worker
      User.auto_worker
    end

    def decrypt_gpg(gpg_string_action:, validate: true, base64: true, tempfile: false)
      query = %Q(bash -c "#{gpg_string_action} |#{base64 ? ' base64 -d |' : ''} \\
        gpg --pinentry-mode loopback \\
        --passphrase #{Rails.application.credentials.dig(:gpg, :passphrase)} \\
        --status-fd #{validate ? 1 : 0} -d")
      if tempfile
        tempfile = Tempfile.new encoding: 'ascii-8bit'
        %x{#{query} > #{tempfile.path}}
        tempfile.rewind
        tempfile
      else
        value = %x{#{query}}.presence&.split("\n")

        if !validate || value&.any? {|l| /^\[GNUPG:\]\s+VALIDSIG\s+#{signing_key_fingerprint}\s+/ }
          [
            value&.select {|l| l !~ /^\[GNUPG:\]/}.join("\n"),
            value&.select {|l| l =~ /^\[GNUPG:\]/},
          ]
        end
      end
    end

    def decrypt_gpg_base64(str, base64: true, validate: true)
      decrypt_gpg(gpg_string_action: "echo '#{str}'", base64: base64, validate: validate)
    end

    def decrypt_gpg_file(path, base64: false, validate: true, tempfile: false)
      decrypt_gpg(gpg_string_action: "cat #{path}", base64: base64, validate: validate, tempfile: tempfile)
    end

    def debugging_trace
      if Rails.env.development?
        trace = TracePoint.new(:call) { |tp| p [tp.path, tp.lineno, tp.event, tp.method_id] }
        trace.enable
        yield
        trace.disable
      else
        yield
      end
    end

    def encrypt_and_encode_str(str)
      %x{bash -c "echo #{str} | gpg -u #{signing_key_fingerprint} -r #{main_key_fingerprint} -s -e | base64 --wrap 0"}
    end

    def generate_qr_code(url, **opts)
      if opts.present?
        RQRCode::QRCode.new(url, **opts)
      else
        RQRCode::QRCode.new(url)
      end
    end

    def normalize_tz_offset(tzo)
      return nil unless tzo.present?

      tzo = tzo.to_i
      tzo = tzo.hours.to_i if tzo.abs < 30

      tzo
    end

    def qr_code_png(url, path, code_opts: {}, png_opts: { size: 500 })
      qr_code = generate_qr_code(url, **code_opts)
      png = png_opts.present? ? qr_code.as_png(**png_opts) : qr_code.as_png
      IO.binwrite(path, png.to_s)
    end

    def qr_code_svg(url, code_opts: {}, svg_opts: {})
      qr_code = generate_qr_code(url, **code_opts)
      svg_opts.present? ? qr_code.as_svg(**svg_opts) : qr_code.as_svg
    end

    def run_sql(*args)
      ActiveRecord::Base.connection.execute(*args) if Rails.env.development?
    end

    def signing_key_fingerprint
      Rails.application.credentials.dig(:gpg, :signing, :fingerprint)
    end

    def main_key_fingerprint
      Rails.application.credentials.dig(:gpg, :fingerprint)
    end

    def test_user_environment_ids
      Rails.env.production? ? test_user_ids : []
    end

    def save_tmp_csv(file_name, data = nil)
      if data.nil?
        data, file_name = file_name, "temp-download.csv"
      end
      save_tmp_file file_name, data
    end

    def save_tmp_file(file_name, body)
      save_to_s3 "tmp/#{file_name}", body
    end

    def save_to_s3(object_path, body)
      [ object_path, s3_bucket.object(object_path).put( body: body ) ]
    end

    def infokit_mail_and_emails(user)
      user = User[user]
      successful, errors = nil
      begin
        if has_ik = user.has_infokit?
          raise "infokit_already_sent" unless Boolean.parse(params[:force])
        end

        unless (u = user.related_athlete) || user.is_coach?
          raise "not_connected_to_an_athlete"
        end

        if u
          unless has_ik
            addr = user.address ||
              u.address ||
              u.guardians.where_exists(:address).limit(1).take&.address ||
              u.backup_guardians.where_exists(:address).limit(1).take&.address ||
              u.related_users.where_exists(:address).limit(1).take&.address

            u.mailings.create!(
              category: :infokit,
              is_home: !!addr,
              address:  addr || u.athlete.school.address
            )
          end

          # ik_message = [ 'Sent Infokit Email' ]
          ik_message = [ 'Sent Infokit Email', "Sent Infokit Email for #{u.team&.sport&.abbr}" ]
          ik_message << 'Sent Kit Followup Email' if has_ik

          User.where(id: [
            user.id,
            (u.contact_histories.where(message: ik_message).limit(1).take ? nil : u)&.id,
            *u.related_users.where.not(email: nil).
            where_not_exists(:contact_histories, message: ik_message).
            pluck(:id)
          ]).each do |ur|
            InfokitMailer.__send__(
              (has_ik ? :send_followup_details : :send_infokit),
              u.category_id, ur.ambassador_email, ur.dus_id, true
            ).deliver_later if ur&.ambassador_email.present?
          end
        else
          InfokitMailer.coach_infokit(user.dus_id).deliver_later
        end

        successful = true
      rescue
        successful = false
        puts (errors = $!.message)
        puts $!.backtrace
      end

      [ successful, errors ]
    end

    def test_user
      User.test_user
    end

    def test_user_ids
      User.test_user_ids
    end

    def tmp_csv_download(file_name = nil)
      file_name = 'temp-download.csv' unless file_name.present?
      path = Rails.root.join('public', file_name)
      s3_bucket.object("tmp/#{file_name}").download_file path
      path
    end

    def url_cache_keys(url)
      key = url_cache_base_key url
      [ key, "#{key}--timestamp" ]
    end

    def url_cache_base_key(url)
      "page_cache.#{DownUnderSports::VERSION}.#{ERB::Util.url_encode(url).gsub(".", '_').underscore}"
    end

    def url_cache_timestamp_key(url)
      "#{url_cache_base_key(url)}--timestamp"
    end

    def visual_trace
      if Rails.env.development?
        require 'visual_call_graph'
        VisualCallGraph.trace { yield }
      else
        yield
      end
    end

    def wrong_school
      School.wrong_school
    end

    def s3_bucket
      return @s3_bucket if @s3_bucket

      require 'aws-sdk-s3'

      Aws.config.update({
        region: Rails.application.credentials.dig(:aws, :region),
        credentials:
          Aws::Credentials.new(
            Rails.application.credentials.dig(:aws, :access_key_id),
            Rails.application.credentials.dig(:aws, :secret_access_key)
          ),
      })

      @s3_bucket = Aws::S3::Resource.new.bucket("#{Rails.application.credentials.dig(:aws, :bucket_name)}-#{(Rails.env.to_s.presence || 'development').downcase}")
    end

    def generate_console_timeout_blocker
      t = Time.zone.now

      -> do
        if Time.zone.now - t > 5.minutes
          puts "\nTIMEOUT BLOCKER\n"
          t = Time.zone.now
        end
      end
    end
end
