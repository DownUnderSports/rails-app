module LegacyData
  def self.get_server_staff_cert(reload: false)
    cert_path = Rails.root.join('staff-cert.pem')
    if !File.exist?(cert_path) || reload
      AesEncryptDir.decrypt(
        input_path: Rails.root.join('staff-cert.pem.tar.b64.aes.gz.b64'),
        output_path: cert_path,
        **Rails.application.credentials.dig(:staff_cert)
      )
    end

    if File.exist? cert_path
      File.read(cert_path)
    else
      ''
    end
  end

  def self.fetch(path)
    result = {}

    begin
      require 'net/https'
      fetcher = Net::HTTP.new('staff.downundersports.com', '443')
      fetcher.use_ssl = true,
      fetcher.verify_mode = OpenSSL::SSL::VERIFY_NONE,
      fetcher.read_timeout = 120
      cert = get_server_staff_cert
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
