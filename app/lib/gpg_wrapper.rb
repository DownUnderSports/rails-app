class GpgWrapper
  class << self
    def decrypt(action:, validate: true, base64: true, tempfile: false)
      query =
        %Q(bash -c "#{action} | ) +
        %Q(#{base64 ? 'base64 -d | ' : ''}) +
        %Q(gpg --pinentry-mode loopback ) +
        %Q(--passphrase #{passphrase} ) +
        %Q(--status-fd #{validate ? 1 : 0} -d")

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

    def encrypt(action:, base64: true, tempfile: false)
      query =
        %Q(bash -c "#{action} | ) +
        %Q(gpg -u #{signing_key_fingerprint} -r #{main_key_fingerprint} -s -e) +
        %Q(#{base64 ? ' | base64 --wrap 0' : ''}")

      if tempfile
        tempfile = Tempfile.new encoding: 'ascii-8bit'
        %x{#{query} > #{tempfile.path}}
        tempfile.rewind
        tempfile
      else
        %x{#{query}}.presence&.strip
      end
    end

    def decrypt_string(str, base64: true, validate: true, tempfile: false)
      result = nil

      open_tempfile do |tmp|
        tmp.write(str + "\n")
        tmp.rewind
        result = decrypt_file(
          tmp.path,
          base64: base64,
          validate: validate,
          tempfile: tempfile
        )
      end

      result
    end

    def decrypt_file(path, base64: false, validate: true, tempfile: false)
      decrypt(
        action: "cat #{path}",
        base64: base64,
        validate: validate,
        tempfile: tempfile
      )
    end

    def encrypt_string(str, base64: true, tempfile: false)
      result = nil
      open_tempfile do |tmp|
        tmp.write(str + "\n")
        tmp.rewind
        result = encrypt_file(
          tmp.path,
          base64: base64,
          tempfile: tempfile
        )
      end

      result
    end

    def encrypt_file(path, base64: false, validate: true, tempfile: false)
      encrypt(
        action: "cat #{path}",
        base64: base64,
        tempfile: tempfile
      )
    end

    private
      def passphrase
        Rails.application.credentials.dig(:gpg, :passphrase)
      end

      def signing_key_fingerprint
        Rails.application.credentials.dig(:gpg, :signing, :fingerprint)
      end

      def main_key_fingerprint
        Rails.application.credentials.dig(:gpg, :fingerprint)
      end

      def open_tempfile
        file = Tempfile.open([ "gpg-#{rand}", '.txt' ], Rails.root.join('tmp'))

        begin
          yield file
        ensure
          file.close!
        end
      end
  end
end
