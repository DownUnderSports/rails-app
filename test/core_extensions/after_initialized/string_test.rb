module CoreExtensions
  module AfterInitialized
    module StringTests
      class ClassMethodTest < ActiveSupport::TestCase
        def assert_distance(distance, a, b)
          assert_equal distance, String.levenshtein_distance(a, b)
        end

        test '.min_of_trio returns the first of three strings alphabetically' do
          assert_equal 'a', String.min_of_trio('a', 'b', 'c')
          assert_equal 'a', String.min_of_trio('b', 'a', 'c')
          assert_equal 'a', String.min_of_trio('b', 'c', 'a')
          assert_equal 'a', String.min_of_trio('c', 'b', 'a')
          assert_equal 'a', String.min_of_trio('c', 'a', 'b')
          assert_equal 'a', String.min_of_trio('a', 'c', 'b')
          assert_equal 'babe', String.min_of_trio('zebra', 'babe', 'charlie')
          assert_equal 'abbacus', String.min_of_trio('actual', 'abra', 'abbacus')
        end

        test  '.levenshtein_distance returns the minimum number of changes' \
              'required to make two strings equal' do
          # test add distance
          assert_distance 2, "zentest", "zntst"
          assert_distance 2, "zntst", "zentest"

          # test empty distance
          assert_distance 5, "abcde", ""
          assert_distance 5, "", "abcde"

          # test remove distance
          assert_distance 3, "zentest", "zentestxxx"
          assert_distance 3, "zentestxxx", "zentest"
          assert_distance 13, "cat", "thundercatsarego"
          assert_distance 13, "thundercatsarego", "cat"

          # test replace distance
          assert_distance 2, "zentest", "ZenTest"
          assert_distance 7, "xxxxxxx", "ZenTest"
          assert_distance 7, "zentest", "xxxxxxx"
        end
      end

      class InstanceMethodsTest < ActiveSupport::TestCase
        def assert_bang_variant(value, bang_method, expected_method = nil, *args)
          dupped = value.dup
          expected_method ||= "#{bang_method}".chomp
          assert_equal value, dupped
          dupped.send bang_method, *args
          refute_equal value, dupped
          assert_equal value.send(expected_method, *args), dupped
        end

        class BasicMethodsTest < InstanceMethodsTest
          test  '#distance_from calls .levenshtein_distance' \
                ' with self and the provided string as args' do
            str = "asdf"
            str_2 = "fdsa"
            called, args = nil
            test_value = ->(*called_with) do
              called = true
              args = called_with
              "WAS CALLED"
            end
            String.stub(:levenshtein_distance, test_value) do
              assert_equal "WAS CALLED", str.distance(str_2)
            end
            assert called
            assert_equal [ str, str_2 ], args
          end

          test '.distance is an alias for .distance_from' do
            str = "asdf"
            str_2 = "fdsa"

            assert_equal str.distance_from(str_2), str.distance(str_2)
            assert_alias_of str, :distance_from, :distance
          end
        end

        class PredicateMethodsTest < InstanceMethodsTest
            def is_time_interval?
              TIME_REGEX.match? self
            end

            test '#is_time_interval? returns whether string is an interval' do
              assert "00:00:00".is_time_interval?
              refute "asdf 00:00:00".is_time_interval?
              refute "00:00:00 becky".is_time_interval?
              assert "00:00:00.00".is_time_interval?
              assert "999:9:99999999999.9999999999999999900".is_time_interval?
              assert "9:9:9.9".is_time_interval?
              refute "9:9:9.".is_time_interval?
            end
        end

        class ExtendedExistingMethodsTest < InstanceMethodsTest
          test "#to_i has been redefined with 'og_to_i'" do
            assert_respond_to "", :og_to_i
            assert_instance_of Integer, "".to_i
            assert_same 0,  "".og_to_i
          end

          test "#to_i converts a time interval to integer seconds" do
            assert_instance_of Integer, "1:0:0".to_i
            assert_same 3600, "1:0:0".to_i
            assert_same 3660, "1:1:0".to_i
            assert_same 3661, "1:1:1".to_i
            assert_same 3661, "1:1:1.1".to_i
            assert_same 1, "1:0:0".og_to_i
          end

          test "#to_d has been redefined with 'og_to_d'" do
            assert_respond_to "", :og_to_d
            assert_equal 0.to_d,  "".og_to_d
            assert_instance_of BigDecimal, "".og_to_d
          end

          test "#to_d converts a time interval to decimal seconds" do
            assert_instance_of BigDecimal, "1:0:0".to_d
            assert_equal 3600, "1:0:0".to_d
            assert_equal 3660, "1:1:0".to_d
            assert_equal 3661, "1:1:1".to_d
            assert_equal 3661.1, "1:1:1.1".to_d
            refute_equal 3661, "1:1:1.1".to_d
            assert_equal 1.to_d, "1:0:0".og_to_d
          end
        end

        class CertificateMethodsTest < InstanceMethodsTest
          DELIMITED_CERTIFICATE = <<-SSL
            -----BEGIN CERTIFICATE-----
            'Stop!'
            said Fred
            -----END CERTIFICATE-----
          SSL

          # #clean_certificate escapes and extracts an encoded SSL certificate
          # body from a string
          test '#clean_certificate removes whitespace from a given string' do
            assert_equal \
              "'Stop!'saidFred",
              "'Stop!'\n said Fred".clean_certificate
          end

          test '#clean_certificate URL decodes a given string' do
            assert_equal \
              "'Stop!'saidFred",
              "%27Stop%21%27%0A+said%20Fred".clean_certificate
          end

          test '#clean_certificate removes SSL delimiters' do
            assert_equal \
              "'Stop!'saidFred",
              DELIMITED_CERTIFICATE.clean_certificate
          end

          test '#clean_certificate! is a bang method for #clean_certificate' do
            assert_bang_variant DELIMITED_CERTIFICATE, :clean_certificate!
          end
        end

        class EncodingMethodsTest < InstanceMethodsTest
          BASE64_ENCODED = [
            "AA==",
            "AAA=",
            "AAAA",
            "/w==",
            "//8=",
            "////",
            "/+8=",
          ]

          BASE64_DECODED = [
            "\0",
            "\0\0",
            "\0\0\0",
            "\377",
            "\377\377",
            "\377\377\377",
            "\xff\xef",
          ]

          test '#from_b64 strict decodes a base64 encoded string' do
            assert_equal "", "".from_b64

            rounds = 0
            BASE64_ENCODED.each_with_index do |str, i|
              rounds += 1
              assert_equal BASE64_DECODED[i], str.from_b64
            end
            assert_equal 7, rounds
          end

          test '#from_b64 raises an ArgumentError on invalid strings' do
            assert_raises(ArgumentError) { "^".from_b64 }
            assert_raises(ArgumentError) { "A".from_b64 }
            assert_raises(ArgumentError) { "A^".from_b64 }
            assert_raises(ArgumentError) { "AA".from_b64 }
            assert_raises(ArgumentError) { "AA=".from_b64 }
            assert_raises(ArgumentError) { "AA===".from_b64 }
            assert_raises(ArgumentError) { "AA=x".from_b64 }
            assert_raises(ArgumentError) { "AAA".from_b64 }
            assert_raises(ArgumentError) { "AAA^".from_b64 }
            assert_raises(ArgumentError) { "AB==".from_b64 }
            assert_raises(ArgumentError) { "AAB=".from_b64 }
          end

          test '#from_b64! is a bang method for #from_b64' do
            assert_equal "", "".from_b64

            rounds = 0
            arr = BASE64_ENCODED.map(&:dup)
            arr.each do |str|
              rounds += 1
              assert_bang_variant str, :from_b64!
            end

            assert_equal 7, rounds
            assert_equal BASE64_DECODED, arr
          end

          test '#rrd_safe' do
            skip '#rrd_safe test needed'
          end
          #   def rrd_safe
          #     dup.rrd_safe!
          #   end
          #

          test '#rrd_safe!' do
            skip '#rrd_safe! test needed'
          end
          #   def rrd_safe!
          #     tr!(TR_REPLACE, TR_REPLACE_WITH)
          #     self
          #   end

          test '#to_b64 strict encodes a string as base64' do
            assert_equal "", "".to_b64

            rounds = 0
            BASE64_DECODED.each_with_index do |str, i|
              rounds += 1
              assert_equal BASE64_ENCODED[i], str.to_b64
            end
            assert_equal 7, rounds
          end

          test '#to_b64! is a bang method for #to_b64' do
            assert_equal "", "".to_b64

            rounds = 0
            arr = BASE64_DECODED.map(&:dup)
            arr.each do |str|
              rounds += 1
              assert_bang_variant str, :to_b64!
            end

            assert_equal 7, rounds
            assert_equal BASE64_ENCODED, arr
          end

          test '#unescape' do
            skip '#unescape test needed'
          end
          #   def unescape
          #     CGI.unescape(self)
          #   end
          #

          test '#unescape!' do
            skip '#unescape! test needed'
          end
          #   def unescape!
          #     self.replace CGI.unescape(self)
          #   end
        end

        class FormatingMethodsTest < InstanceMethodsTest
          test '#abbr_format' do
            skip '#abbr_format test needed'
          end
          #   def abbr_format
          #     dup.abbr_format!
          #   end

          test '#abbr_format!' do
            skip '#abbr_format! test needed'
          end
          #   def abbr_format!
          #     upcase!
          #     gsub!(/[^A-Z]/, '')
          #     slice!(3..-1)
          #     self
          #   end

          test '#cleanup' do
            skip '#cleanup test needed'
          end
          #   def cleanup
          #     dup.cleanup!
          #   end

          test '#cleanup!' do
            skip '#cleanup! test needed'
          end
          #   def cleanup!
          #     gsub!(/\s*(?:\r?\n\s*|\s+)/, ' ')
          #     self
          #   end

          test '#cleanup_production' do
            skip '#cleanup_production test needed'
          end
          #   def cleanup_production
          #     Rails.env.production? \
          #       ? cleanup
          #       : self
          #   end

          test '#decrypt_token' do
            skip '#decrypt_token test needed'
          end
          #   def decrypt_token
          #     JSON.parse(decrypt_gpg_base64(str.strip))
          #   end

          test '#decrypt_token!' do
            skip '#decrypt_token! test needed'
          end
          #   def decrypt_token!
          #     self.replace decrypt_token
          #   end

          test '#dup' do
            skip '#dup test needed'
          end
          #   def dup
          #     self + ''
          #   end

          test '#dus_id_format' do
            skip '#dus_id_format test needed'
          end
          #   def dus_id_format
          #     dup.dus_id_format!
          #   end

          test '#dus_id_format!' do
            skip '#dus_id_format! test needed'
          end
          #   def dus_id_format!
          #     upcase!
          #     gsub!(/[^A-Z]/, '')
          #     slice!(6..-1)
          #     self
          #   end

          test '#phone_format' do
            skip '#phone_format test needed'
          end
          #   def phone_format
          #     dup.phone_format!
          #   end

          test '#phone_format!' do
            skip '#phone_format! test needed'
          end
          #   def phone_format!
          #     return '' unless present?
          #
          #     strip_phone_prefix!
          #
          #     return self if length < 10
          #
          #     case self
          #     when /^\+6/
          #       format_aussie_phone_six!
          #     when /^04/
          #       format_aussie_phone_four!
          #     when /^0/
          #       format_aussie_phone_other!
          #     else
          #       format_us_phone!
          #     end
          #
          #     self
          #   end

          test '#titleize(name: true, keep_id_suffix: false)' do
            skip '#titleize(name: true, keep_id_suffix: false) test needed'
          end
          #   def titleize(name: true, keep_id_suffix: false)
          #     ActiveSupport::Inflector.titleize(self, name: name, keep_id_suffix: name || keep_id_suffix)
          #   end

          test '#us_date_to_iso' do
            skip '#us_date_to_iso test needed'
          end
          #   def us_date_to_iso
          #     dup.us_date_to_iso!
          #   end

          test '#us_date_to_iso!' do
            skip '#us_date_to_iso! test needed'
          end
          #   def us_date_to_iso!
          #     m, d, y = self.split('/')
          #     replace("20#{y.rjust(4, '0')[-2..-1]}-#{m.rjust(2, '0')}-#{d.rjust(2, '0')}")
          #   end

          test '#us_date_to_iso_if_needed' do
            skip '#us_date_to_iso_if_needed test needed'
          end
          #   def us_date_to_iso_if_needed
          #     dup.us_date_to_iso_if_needed!
          #   end

          test '#us_date_to_iso_if_needed!' do
            skip '#us_date_to_iso_if_needed! test needed'
          end
          #   def us_date_to_iso_if_needed!
          #     if self =~ /\d+\/\d+\/\d+/
          #       us_date_to_iso!
          #     else
          #       self
          #     end
          #   end
        end
      end
    end
  end
end
