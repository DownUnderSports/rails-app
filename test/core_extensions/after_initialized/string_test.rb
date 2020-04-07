module CoreExtensions
  module AfterInitialized
    module StringTests
      class ClassMethodTest < ActiveSupport::TestCase
        def assert_distance(distance, a, b)
          assert_equal distance, String.levenshtein_distance(a, b)
        end

        test '.levenshtein_distance returns the minimum number of changes' \
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
          test '#distance_from calls .levenshtein_distance' \
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

          test '#fast_dup creates a new string by adding a blank string' do
            String.stub_instances(:+, 'asdf') do
              assert_equal "asdf", ''.fast_dup
            end

            str = 'asdf'

            refute_same str, str.fast_dup
            assert_equal str, str.fast_dup

            str = "#{rand} random string"

            refute_same str, str.fast_dup
            assert_equal str, str.fast_dup
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

          def sample_unsafe_print
            String::TR_REPLACE.split("").shuffle[0..10].join
          end

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
            assert_equal "", "".from_b64!

            rounds = 0
            arr = BASE64_ENCODED.map(&:dup)
            arr.each do |str|
              rounds += 1
              assert_bang_variant str, :from_b64!
            end

            assert_equal 7, rounds
            assert_equal BASE64_DECODED, arr
          end

          test '#print_safe' do
            10.times do
              str = sample_unsafe_print
              safe = str.print_safe
              str.split("").each_with_index do |char, idx|
                loc = String::TR_REPLACE.index(char)
                assert_equal String::TR_REPLACE_WITH[loc], safe[idx]
              end
            end
          end

          test '#print_safe!' do
            arr = []
            10.times { arr << sample_unsafe_print }

            rounds = 0
            ran = arr.map(&:dup)

            ran.each do |str|
              rounds += 1
              assert_bang_variant str, :print_safe!
            end

            assert_equal 10, rounds
            assert_equal arr.map(&:print_safe), ran
          end

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
            assert_equal "", "".to_b64!

            rounds = 0
            arr = BASE64_DECODED.map(&:dup)
            arr.each do |str|
              rounds += 1
              assert_bang_variant str, :to_b64!
            end

            assert_equal 7, rounds
            assert_equal BASE64_ENCODED, arr
          end

          test '#unescape url-decodes the string' do
            input    = "+%21%22%23%24%25%26%27%28%29%2A%2B%2C-.%2F0123456789" \
                       "%3A%3B%3C%3D%3E%3F%40ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5" \
                       "C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D%7E"

            expected = " !\"\#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQ" \
                       "RSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

            assert_equal expected, input.unescape
            assert_equal CGI.unescape(input), input.unescape

            input    = 'http%3A%2F%2Fja.wikipedia.org%2Fwiki%2F%E3%83%AD%E3' \
                       '%83%A0%E3%82%B9%E3%82%AB%E3%83%BB%E3%83%91%E3%83%AD' \
                       '%E3%83%BB%E3%82%A6%E3%83%AB%E3%83%BB%E3%83%A9%E3%83' \
                       '%94%E3%83%A5%E3%82%BF'
            expected = "http://ja.wikipedia.org/wiki/\343\203\255\343\203" \
                       "\240\343\202\271\343\202\253\343\203\273\343\203" \
                       "\221\343\203\255\343\203\273\343\202\246\343\203" \
                       "\253\343\203\273\343\203\251\343\203\224\343\203" \
                       "\245\343\202\277"

            assert_equal expected, input.unescape
            assert_equal CGI.unescape(input), input.unescape
          end

          test '#unescape passes self to CGI.unescape' do
            str = "#{rand} random string"
            called = called_with = false
            test_value = ->(*args) do
              called = true
              called_with = args
              "WAS CALLED"
            end
            CGI.stub(:unescape, test_value) do
              assert_equal "WAS CALLED", str.unescape
            end

            assert called

            assert_equal [ str ], called_with
          end

          test '#unescape! is a bang method for unescape' do
            base = "+%21%22%23%24%25%26%27%28%29%2A%2B%2C-.%2F0123456789" \
                   "%3A%3B%3C%3D%3E%3F%40ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5" \
                   "C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D%7E"
            input = base.dup

            assert_equal base.unescape, input.unescape!
            refute_equal base, input
            assert_equal base.unescape, input

            assert_bang_variant base, :unescape!
          end
        end

        class FormatingMethodsTest < InstanceMethodsTest
          TO_TITLECASE_WITH_ID = {
            "this_is_a_string_ending_with_id" => "This Is A String Ending With Id",
            "EmployeeId"                      => "Employee Id",
            "Author Id"                       => "Author Id"
          }

          TO_TITLECASE = {
            "active_record"         => "Active Record",
            "ActiveRecord"          => "Active Record",
            "action web service"    => "Action Web Service",
            "Action Web Service"    => "Action Web Service",
            "Action web service"    => "Action Web Service",
            "actionwebservice"      => "Actionwebservice",
            "Actionwebservice"      => "Actionwebservice",
            "david's code"          => "David's Code",
            "David's code"          => "David's Code",
            "david's Code"          => "David's Code",
            "sgt. pepper's"         => "Sgt. Pepper's",
            "i've just seen a face" => "I've Just Seen A Face",
            "maybe you'll be there" => "Maybe You'll Be There",
            "¿por qué?"             => "¿Por Qué?",
            "Fred’s"                => "Fred’s",
            "Fred`s"                => "Fred`s",
            "this was 'fake news'"  => "This Was 'Fake News'",
            "string_ending_with_id" => "String Ending With",
            ActiveSupport::SafeBuffer.new("confirmation num") => "Confirmation Num",
          }

          test '#abbr_format upcases and returns a max of 3 letters' do
            assert_equal "ASD", "asdf".abbr_format
            assert_equal "AF", "af".abbr_format
            assert_equal "ASD", "asDf".abbr_format
            assert_equal "ASD", "a-S%^90df".abbr_format
            assert_equal "AD", "1243A-%^90d8".abbr_format
            assert_equal "AAD", "a1243A-%^90d8".abbr_format
          end

          test '#abbr_format! is a bang method for #abbr_format' do
            assert_equal "ASD", "asdf".abbr_format!
            assert_equal "AF", "af".abbr_format!
            assert_equal "ASD", "asDf".abbr_format!
            assert_equal "ASD", "a-S%^90df".abbr_format!
            assert_equal "AD", "1243A-%^90d8".abbr_format!
            assert_equal "AAD", "a1243A-%^90d8".abbr_format!

            assert_bang_variant "1243a-%^90d8F", :abbr_format!
          end

          test '#cleanup converts all whitespace to a single space' do
            assert_equal " ", "\s\s".cleanup
            assert_equal " ", "\n".cleanup
            assert_equal " ", "\r\s\n\n \s\n".cleanup
            assert_equal " b ", "\r\s\n\n b\s\n".cleanup
            assert_equal " a b c", "\ra\s\nb c".cleanup
            assert_equal "1243a- %^ 90 d 8F", "1243a-\s%^\n90 d\r8F".cleanup
          end

          test '#cleanup! is a bang method for #cleanup' do
            assert_equal " ", "\s\s".cleanup!
            assert_equal " ", "\n".cleanup!
            assert_equal " ", "\r\s\n\n \s\n".cleanup!
            assert_equal " b ", "\r\s\n\n b\s\n".cleanup!
            assert_equal " a b c", "\ra\s\nb c".cleanup!
            assert_equal "1243a- %^ 90 d 8F", "1243a-\s%^\n90 d\r8F".cleanup!

            assert_bang_variant "1243a-\s%^\n90 d\r8F", :cleanup!
          end

          test '#cleanup_production calls cleanup only in development' do
            # #cleanup should not be called in test or development
            # incorrectly calling will raise an error and stop tests
            raise_if_called = ->() { raise StandardError.new('#cleanup was called') }
            String.stub_instances(:cleanup, raise_if_called) do
              Rails.stub(:env, ActiveSupport::StringInquirer.new("development")) do
                "".cleanup_production
              end
              Rails.stub(:env, ActiveSupport::StringInquirer.new("test")) do
                "".cleanup_production
              end
              Rails.stub(:env, ActiveSupport::StringInquirer.new("production")) do
                error = assert_raises(StandardError) do
                  "".cleanup_production
                end
                assert_equal '#cleanup was called', error.message
              end
            end

            [
              "\s\s",
              "\n",
              "\r\s\n\n \s\n",
              "\r\s\n\n b\s\n",
              "\ra\s\nb c",
              "1243a-\s%^\n90 d\r8F",
            ].each do |value|
              Rails.stub(:env, ActiveSupport::StringInquirer.new("development")) do
                assert_equal value, value.cleanup_production
                refute_equal value.cleanup, value.cleanup_production
              end
              Rails.stub(:env, ActiveSupport::StringInquirer.new("test")) do
                assert_equal value, value.cleanup_production
                refute_equal value.cleanup, value.cleanup_production
              end
              Rails.stub(:env, ActiveSupport::StringInquirer.new("production")) do
                refute_equal value, value.cleanup_production
                assert_equal value.cleanup, value.cleanup_production
              end
            end
          end

          test '#dus_id_format upcases and returns the first 6 letters' do
            assert_equal "AB", "1234567890a!@#$%^&*()_+{}|b:\"\"''".dus_id_format
            assert_equal "ABCDEF", "abcDEFgHIJkl".dus_id_format
          end

          test '#dus_id_format! is a bang method for #dus_id_format' do
            assert_equal "AB", "1234567890a!@#$%^&*()_+{}|b:\"\"''".dus_id_format!
            assert_equal "ABCDEF", "abcDEFgHIJkl".dus_id_format!
            assert_bang_variant "abcDEFgHIJkl", :dus_id_format!
          end

          test '#phone_format' do
            assert_equal "435-753-4732", "+14357534732".phone_format
            assert_equal "", "ASDF".phone_format
            assert_equal "1", "A1SDF".phone_format
            assert_equal "+61 404 068 889", "+610404068889".phone_format
            assert_equal "0404 068 889", "0404068889".phone_format
          end

          test '#phone_format! is a bang method for #phone_format' do
            assert_equal "435-753-4732", "+14357534732".phone_format!
            assert_equal "", "ASDF".phone_format!
            assert_equal "1", "A1SDF".phone_format!
            assert_equal "+61 404 068 889", "+610404068889".phone_format!
            assert_equal "0404 068 889", "0404068889".phone_format!

            assert_bang_variant "4357534732", :phone_format!
          end

          test '#titleize calls ActiveSupport::Inflector#titleize with equal defaults' do
            TO_TITLECASE.each do |(started_with, expected)|
              assert_equal expected, started_with.titleize
            end

            TO_TITLECASE_WITH_ID.each do |(started_with, expected)|
              assert_equal expected, started_with.titleize(keep_id_suffix: true)
            end
          end

          test '#us_date_to_iso splits the string on each forward slash and rearranges it to be ISO formatted' do
            assert_equal '20EF-AB-CD', 'AB/CD/EF'.us_date_to_iso
            assert_equal '2020-12-01', '12/01/20'.us_date_to_iso
            assert_equal '2019-12-01', '12/01/2019'.us_date_to_iso
          end

          test '#us_date_to_iso! is a bang method for #us_date_to_iso' do
            assert_equal '20EF-AB-CD', 'AB/CD/EF'.us_date_to_iso!
            assert_equal '2020-12-01', '12/01/20'.us_date_to_iso!
            assert_equal '2019-12-01', '12/01/2019'.us_date_to_iso!
            assert_bang_variant "12/01/2019", :us_date_to_iso!
          end

          test '#us_date_to_iso_if_needed calls us_date_to_iso if the date if formatted \d+/\d+/\d+' do
            assert_equal 'AB/CD/EF', 'AB/CD/EF'.us_date_to_iso_if_needed
            assert_equal '2020-12-01', '12/01/20'.us_date_to_iso_if_needed
            assert_equal '2019-12-01', '12/01/2019'.us_date_to_iso_if_needed
          end

          test '#us_date_to_iso_if_needed! is a bang method for #us_date_to_iso_if_needed' do
            assert_equal 'AB/CD/EF', 'AB/CD/EF'.us_date_to_iso_if_needed!
            assert_equal '2020-12-01', '12/01/20'.us_date_to_iso_if_needed!
            assert_equal '2019-12-01', '12/01/2019'.us_date_to_iso_if_needed!
            assert_bang_variant "12/01/2019", :us_date_to_iso_if_needed!
          end
        end
      end
    end
  end
end
