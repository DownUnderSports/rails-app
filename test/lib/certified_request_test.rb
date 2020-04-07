# encoding: utf-8
# frozen_string_literal: true
module Libraries
  class CertifiedRequestTest < ActiveSupport::TestCase
    test '.get_certificate_path returns the absolute path to "server-certificate.pem" at Rails.root' do
      assert_instance_of Pathname, CertifiedRequest.get_certificate_path
      assert_equal __dir__.sub(/\/test\/lib/, '/') + 'server-certificate.pem', CertifiedRequest.get_certificate_path.to_s
    end

    test '.delete_existing removes a file if it exists' do
      tmp_file = Rails.root.join('tmp', "#{rand}-does-not-exist")
      refute File.exist?(tmp_file)
      refute CertifiedRequest.delete_existing(tmp_file)
      File.open(tmp_file, "w") {}
      assert File.exist?(tmp_file)
      assert_equal 1, CertifiedRequest.delete_existing(tmp_file)
    end

    test '.decrypt_file calls AesEncryptDir.decrypt with :server_certificate credentials' do
      given_opts = nil
      expected_opts = {
        key: Rails.application.credentials.dig(:server_certificate, :key),
        iv: Rails.application.credentials.dig(:server_certificate, :iv),
        tag: Rails.application.credentials.dig(:server_certificate, :tag),
        auth_data: Rails.application.credentials.dig(:server_certificate, :auth_data),
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

    test '.get_server_certificate returns the decrypted text content of server-certificate.pem.tar.b64.aes.gz.b64' do
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
      assert_equal CertifiedRequest.read_existing(CertifiedRequest.get_certificate_path), CertifiedRequest.get_server_certificate
      assert_match is_match_regex, CertifiedRequest.get_server_certificate
    end

    test '.fetch authenticates with the given domain and makes an HTTP request to the given path' do
      skip "Test Needed"
    end
  end
end
# module CertifiedRequest
#   def self.fetch(domain: 'staff.downundersports.com', path:)
#     result = {}
#
#     begin
#       require 'net/https'
#       fetcher = Net::HTTP.new(domain, '443')
#       fetcher.use_ssl = true,
#       fetcher.verify_mode = OpenSSL::SSL::VERIFY_NONE,
#       fetcher.read_timeout = 120
#
#       cert = get_server_certificate
#
#       if cert.present?
#         fetcher.cert = OpenSSL::X509::Certificate.new( cert )
#         fetcher.key = OpenSSL::PKey::RSA.new( cert, nil )
#       end
#
#       fetcher.start do |https|
#         request = Net::HTTP::Get.new(path)
#         if block_given?
#           result = yield(https, request)
#         else
#           response = https.request(request)
#           response.value
#           result = JSON.parse(response.body)
#         end
#       end
#     rescue
#       puts $!.message
#       puts $!.backtrace
#       result = {}
#     end
#
#     result
#   end
# end
