# encoding: utf-8
# frozen_string_literal: true
module Libraries
  class CertifiedRequestTest < ActiveSupport::TestCase
    test '.get_certificate_path returns the absolute path to "/config/certificates/client-certificate.pem" at Rails.root' do
      assert_instance_of Pathname, CertifiedRequest.get_certificate_path
      assert_equal __dir__.sub(/\/test\/lib/, '/config/certificates/') + 'client-certificate.pem', CertifiedRequest.get_certificate_path.to_s
    end

    test '.delete_existing removes a file if it exists' do
      tmp_file = Rails.root.join('tmp', "#{rand}-does-not-exist")
      refute File.exist?(tmp_file)
      refute CertifiedRequest.delete_existing(tmp_file)
      File.open(tmp_file, "w") {}
      assert File.exist?(tmp_file)
      assert_equal 1, CertifiedRequest.delete_existing(tmp_file)
    end

    test '.decrypt_file calls AesEncryptDir.decrypt with :client_certificate credentials' do
      given_opts = nil
      expected_opts = {
        key: Rails.application.credentials.dig(:client_certificate, :key),
        iv: Rails.application.credentials.dig(:client_certificate, :iv),
        tag: Rails.application.credentials.dig(:client_certificate, :tag),
        auth_data: Rails.application.credentials.dig(:client_certificate, :auth_data),
        input_path: 'test-path.tar.b64.aes.gz.b64',
        output_path: 'test-path',
      }

      AesEncryptDir.stub(:decrypt, ->(**opts) { given_opts = opts }) do
        CertifiedRequest.decrypt_file('test-path')
      end

      assert_equal expected_opts, given_opts
    end

    test '.read_existing reads a file if it exists' do
      tmp_file = Rails.root.join('tmp', "#{rand}-does-not-exist")
      refute File.exist?(tmp_file)
      assert_equal '', CertifiedRequest.read_existing(tmp_file)
      File.open(tmp_file, "w") {|f| f.write('asdf')}
      assert File.exist?(tmp_file)
      assert_equal 'asdf', CertifiedRequest.read_existing(tmp_file)
      CertifiedRequest.delete_existing(tmp_file)
    end

    test '.get_client_certificate returns the decrypted text content of client-certificate.pem.tar.b64.aes.gz.b64' do
      is_match_regex = %r{
        .*O\s*=\s*\"International\sSports\sSpecialists,\sInc\.\"
        .*
        emailAddress\s*=\s*.+@downundersports\.com
        .*
        -+BEGIN\s+CERTIFICATE-+
        .*
        -+END\s+CERTIFICATE-+
        .*
        -+BEGIN\s+PRIVATE\s+KEY-+
        .*
        -+END\s+PRIVATE\s+KEY-+
        \n+
      }mx
      CertifiedRequest.decrypt_file(CertifiedRequest.get_certificate_path)
      assert_equal CertifiedRequest.read_existing(CertifiedRequest.get_certificate_path), CertifiedRequest.get_client_certificate
      assert_match is_match_regex, CertifiedRequest.get_client_certificate
    end

    test '.fetch authenticates with the given domain and makes an HTTP request to the given path' do
      fetcher = nil
      stubbed_start = ->(*args, **opts, &block) do
        fetcher = self
        self.__send__ :unstubbed_start, *args, **opts, &block
      end
      stub_args = [ :start,  stubbed_start]
      stub_opts = {
        keep_self: true,
        pass_sub_block: true,
        stub_name: :unstubbed_start
      }

      Net::HTTP.stub_instances(*stub_args, **stub_opts) do
        expected_result = { "test_key" => "test_value", "success" => "true"}
        received_result =
          CertifiedRequest.
            fetch(
              domain: 'authorize.downundersports.com',
              path: '/testing/authenticated.json'
            )

        assert_equal expected_result, received_result
        assert_instance_of Net::HTTP, fetcher
        assert fetcher.use_ssl?
        assert_equal OpenSSL::SSL::VERIFY_PEER, fetcher.verify_mode
        assert_equal 'authorize.downundersports.com', fetcher.address
        assert_instance_of OpenSSL::X509::Store, fetcher.cert_store
        assert_equal CertifiedRequest.get_root_ca_cert_store, fetcher.cert_store
        assert_instance_of OpenSSL::X509::Certificate, fetcher.cert
        assert_instance_of OpenSSL::PKey::RSA, fetcher.key

        # client certificates should only be validated against the company CA
        fetcher = nil
        basic_cert_store = CertifiedRequest.get_cert_store
        assert_nil fetcher
        err = assert_raises(OpenSSL::SSL::SSLError) do
          CertifiedRequest.fetch \
            domain: 'authorize.downundersports.com',
            path: '/testing/authenticated.json',
            cert_store: basic_cert_store
        end

        assert_equal "SSL_connect returned=1 errno=0 state=error: certificate verify failed (self signed certificate in certificate chain)", err.message

        assert_instance_of Net::HTTP, fetcher
        assert_equal basic_cert_store, fetcher.cert_store
        refute_equal CertifiedRequest.get_root_ca_cert_store, fetcher.cert_store

        # invalid locations still contain the right setup
        random_domain = "#{rand}-invalid-domain.com"
        err = assert_raises(SocketError) do
          CertifiedRequest.fetch(domain: random_domain, path: '/')
        end

        assert_equal "Failed to open TCP connection to #{random_domain}:443 (getaddrinfo: Name or service not known)", err.message

        assert_instance_of Net::HTTP, fetcher
        assert fetcher.use_ssl?
        assert_equal CertifiedRequest.get_root_ca_cert_store, fetcher.cert_store
        assert_equal OpenSSL::SSL::VERIFY_PEER, fetcher.verify_mode
        assert_equal random_domain, fetcher.address
        assert_instance_of OpenSSL::X509::Certificate, fetcher.cert
        assert_instance_of OpenSSL::PKey::RSA, fetcher.key
      end
    end

    test '.fetch yields the Net::HTTP instance if a block is given' do
      CertifiedRequest.fetch(domain: 'httpstat.us') do |http|
        assert_instance_of Net::HTTP, http
        assert http.started?
        response = http.request(Net::HTTP::Get.new("/200"))
        assert_kind_of Net::HTTPResponse, response
        assert_instance_of Net::HTTPOK, response
        assert_equal '200', response.code
        assert_equal '200 OK', response.body
      end
    end


    test '.fetch :timeout has a min of 5 and a max of 120 seconds' do
      fetcher = nil
      stubbed_start = ->() { fetcher = self }

      stub_args = [ :start,  stubbed_start]
      stub_opts = { keep_self: true }

      Net::HTTP.stub_instances(*stub_args, **stub_opts) do
        CertifiedRequest.fetch(timeout: 121)
        assert fetcher
        assert_equal 120, fetcher.read_timeout
        CertifiedRequest.fetch(timeout: 4)
        assert_equal 5, fetcher.read_timeout
        CertifiedRequest.fetch(timeout: 90)
        assert fetcher
        assert_equal 90, fetcher.read_timeout
      end
    end

    test '.fetch times out after the timeout value' do
      opts = { domain: 'httpstat.us', path: '/200?sleep=5100' }

      assert_raises(Net::ReadTimeout) do
        CertifiedRequest.fetch(**opts, timeout: 5)
      end

      CertifiedRequest.fetch(**opts, timeout: 6) do |http|
        response = http.request(Net::HTTP::Get.new(opts[:path]))
        assert_kind_of Net::HTTPResponse, response
        assert_instance_of Net::HTTPOK, response
        assert_equal '200', response.code
        assert_equal '200 OK', response.body
      end
    end
  end
end
