module CertifiedRequest
  def self.get_certificate_path
    Rails.root.join('server-certificate.pem')
  end

  def self.delete_existing(file_path)
    File.delete(file_path) if File.exist?(file_path)
  end

  def self.decrypt_file(file_path)
    AesEncryptDir.decrypt(
      input_path: file_path.to_s + '.tar.b64.aes.gz.b64',
      output_path: file_path,
      **Rails.application.credentials.dig(:server_certificate)
    )
  end

  def self.read_existing(file_path)
    File.exist?(file_path) ? File.read(file_path) : ''
  end

  def self.get_server_certificate(reload: false)
    certificate_path = get_certificate_path

    delete_existing(certificate_path) if reload

    decrypt_file(certificate_path) if !File.exist?(certificate_path)

    read_existing(certificate_path)
  end

  def self.fetch(domain: 'staff.downundersports.com', path:)
    result = {}

    begin
      require 'net/https'
      fetcher = Net::HTTP.new(domain, '443')
      fetcher.use_ssl = true,
      fetcher.verify_mode = OpenSSL::SSL::VERIFY_NONE,
      fetcher.read_timeout = 120

      cert = get_server_certificate

      if cert.present?
        fetcher.cert = OpenSSL::X509::Certificate.new( cert )
        fetcher.key = OpenSSL::PKey::RSA.new( cert, nil )
      end

      fetcher.start do |https|
        request = Net::HTTP::Get.new(path)
        if block_given?
          result = yield(https, request)
        else
          response = https.request(request)
          response.value
          result = JSON.parse(response.body)
        end
      end
    rescue
      puts $!.message
      puts $!.backtrace
      result = {}
    end

    result
  end
end
