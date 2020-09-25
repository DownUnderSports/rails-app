module CertifiedRequest
  class << self
    def get_certificate_path
      Rails.root.join("config", "certificates", "client-certificate.pem")
    end

    def get_ca_cert_store_path
      Rails.root.join("config", "certificates", "dus-root-ca.pem")
    end

    def delete_existing(file_path)
      File.delete(file_path) if File.exist?(file_path)
    end

    def decrypt_file(file_path, **options)
      TarEncryptGun.decrypt(
        input: file_path.to_s + ".tar.nacl.gz",
        output: file_path,
        chmod: 0400,
        **Rails.application.credentials.dig(:client_certificate),
        **options
      )
    end

    def read_existing(file_path)
      File.exist?(file_path) ? File.read(file_path) : ""
    end

    def get_client_certificate(reload: false)
      decrypt_and_read_file(get_certificate_path, reload: reload)
    end

    def decrypt_and_read_file(file_path, reload: false, **opts)
      delete_existing(file_path) if reload

      decrypt_file(file_path, **opts) if !File.exist?(file_path)

      read_existing(file_path)
    end

    def get_cert_store(paths = nil)
      require "net/https"
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      paths&.each do |path|
        if path.respond_to?(:deconstruct)
          store.add_cert(
            OpenSSL::X509::Certificate.new(
              case path
              in [ file_path, { decrypt: true, **opts }]
                Rails.logger.debug "Decrypting Certificate Store: #{file_path}"
                decrypt_and_read_file file_path, **opts
              in [ file_path ]
                Rails.logger.debug "Reading Certificate Store: #{file_path}"
                read_existing file_path
              else
                raise OpenSSL::X509::CertificateError.new("No certificate given")
              end
            )
          )
        elsif path.present?
          store.add_cert OpenSSL::X509::Certificate.new(read_existing(path))
        else
          raise OpenSSL::X509::CertificateError.new("No certificate given")
        end
      end
      store
    end

    def get_root_ca_cert_store(reload: false)
      @root_store = nil if reload
      @root_store ||= get_cert_store([
        [
          get_ca_cert_store_path,
          decrypt: true,
          **Rails.application.credentials.dig(:root_certificate)
        ]
      ])
    end

    def fetch(domain: "staff.downundersports.com", path: nil, request: nil, cert_store: nil, timeout: 120)
      result = {}

      require "net/https"
      fetcher = Net::HTTP.new(domain, "443")
      fetcher.use_ssl = true,
      fetcher.cert_store = cert_store || get_root_ca_cert_store
      fetcher.verify_mode = OpenSSL::SSL::VERIFY_PEER
      fetcher.read_timeout = timeout.to_i.min_max(5, 120)

      cert = get_client_certificate

      if cert.present?
        fetcher.cert = OpenSSL::X509::Certificate.new( cert )
        fetcher.key = OpenSSL::PKey::RSA.new( cert, nil )
      end

      fetcher.start do |https|
        if block_given?
          result = yield(https)
        else
          request ||= Net::HTTP::Get.new(path)
          response = https.request(request)
          response.value
          result = JSON.parse(response.body)
        end
      end

      result
    end
  end
end
