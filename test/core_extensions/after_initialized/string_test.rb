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

      class InstanceMethodTest < ActiveSupport::TestCase
        DELIMITED_CERTIFICATE = <<-SSL
          -----BEGIN CERTIFICATE-----
          'Stop!'
          said Fred
          -----END CERTIFICATE-----
        SSL

        def assert_bang_variant(value, bang_method, expected_method = nil, *args)
          dupped = value.dup
          expected_method ||= "#{bang_method}".chomp
          assert_equal value, dupped
          dupped.send bang_method, *args
          refute_equal value, dupped
          assert_equal value.send(expected_method, *args), dupped
        end

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
    end
  end
end

# class String
#   TR_REPLACE =      "ÀÁÂÃÄÅàáâãäåĀāĂăĄą" \
#                     "ÇçĆćĈĉĊċČč" \
#                     "ÐðĎďĐđ" \
#                     "ÈÉÊËèéêëĒēĔĕĖėĘęĚě" \
#                     "ĜĝĞğĠġĢģ" \
#                     "ĤĥĦħ" \
#                     "ÌÍÎÏìíîïĨĩĪīĬĭĮįİı" \
#                     "Ĵĵ" \
#                     "Ķķĸ" \
#                     "ĹĺĻļĽľĿŀŁł" \
#                     "ÑñŃńŅņŇňŉŊŋ" \
#                     "ÒÓÔÕÖØòóôõöøŌōŎŏŐő" \
#                     "ŔŕŖŗŘř" \
#                     "ŚśŜŝŞşŠšȘș" \
#                     "ſŢţŤťŦŧȚț" \
#                     "ÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲų" \
#                     "Ŵŵ" \
#                     "ÝýÿŶŷŸ" \
#                     "ŹźŻżŽž" \
#                     "“‘”’’".freeze
#
#   TR_REPLACE_WITH = "AAAAAAaaaaaaAaAaAa" \
#                     "CcCcCcCcCc" \
#                     "DdDdDd" \
#                     "EEEEeeeeEeEeEeEeEe" \
#                     "GgGgGgGg" \
#                     "HhHh" \
#                     "IIIIiiiiIiIiIiIiIi" \
#                     "Jj" \
#                     "Kkk" \
#                     "LlLlLlLlLl" \
#                     "NnNnNnNnnNn" \
#                     "OOOOOOooooooOoOoOo" \
#                     "RrRrRr" \
#                     "SsSsSsSsSss" \
#                     "TtTtTtTt" \
#                     "UUUUuuuuUuUuUuUuUuUu" \
#                     "Ww" \
#                     "YyyYyY" \
#                     "ZzZzZz" \
#                     "\"\'\"\'\'".freeze
#
#   def clean_certificate
#     dup.clean_certificate!
#   end
#
#   def clean_certificate!
#     unescape!
#     strip!
#     delete_prefix! "-----BEGIN CERTIFICATE-----"
#     delete_suffix! "-----END CERTIFICATE-----"
#     delete! "\n\s"
#     self
#   end
#
#   def cleanup
#     dup.cleanup!
#   end
#
#   def cleanup!
#     gsub!(/\s*(?:\r?\n\s*|\s+)/, ' ')
#     self
#   end
#
#   def cleanup_production
#     Rails.env.production? \
#       ? cleanup
#       : self
#   end
#
#
#   def dup
#     self + ''
#   end
#
#   def rrd_safe
#     dup.rrd_safe!
#   end
#
#   def rrd_safe!
#     tr!(TR_REPLACE, TR_REPLACE_WITH)
#     self
#   end
#
#   def abbr_format
#     dup.abbr_format!
#   end
#
#   def abbr_format!
#     upcase!
#     gsub!(/[^A-Z]/, '')
#     slice!(3..-1)
#     self
#   end
#
#   def decrypt_token
#     JSON.parse(decrypt_gpg_base64(str.strip))
#   end
#
#   def decrypt_token!
#     self.replace decrypt_token
#   end
#
#   def dus_id_format
#     dup.dus_id_format!
#   end
#
#   def dus_id_format!
#     upcase!
#     gsub!(/[^A-Z]/, '')
#     slice!(6..-1)
#     self
#   end
#
#   def phone_format
#     dup.phone_format!
#   end
#
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
#
#   def unescape
#     CGI.unescape(self)
#   end
#
#   def unescape!
#     self.replace CGI.unescape(self)
#   end
#
#   def titleize(name: true, keep_id_suffix: false)
#     ActiveSupport::Inflector.titleize(self, name: name, keep_id_suffix: name || keep_id_suffix)
#   end
#
#   def distance(str)
#     self.class.levenshtein_distance(self, str)
#   end
#
#   unless defined?(og_to_i)
#     alias :og_to_d :to_d
#     alias :og_to_i :to_i
#
#     def to_i
#       begin
#         is_time_interval? ? to_d.to_i : og_to_i
#       rescue
#         og_to_i
#       end
#     end
#
#     def to_d
#       begin
#         if is_time_interval?
#           self.split(':').
#             map { |a| a.to_d }.
#             inject(0) { |a, b| a * BigDecimal(60) + b}
#         else
#           og_to_d
#         end
#       rescue
#         og_to_d
#       end
#     end
#   end
#
#   def from_b64
#     dup.from_b64!
#   end
#
#   def from_b64!
#     replace(Base64.strict_decode64(self))
#   end
#
#   def to_b64
#     dup.to_b64!
#   end
#
#   def to_b64!
#     replace(Base64.strict_encode64(self))
#   end
#
#   def us_date_to_iso
#     dup.us_date_to_iso!
#   end
#
#   def us_date_to_iso!
#     m, d, y = self.split('/')
#     replace("20#{y.rjust(4, '0')[-2..-1]}-#{m.rjust(2, '0')}-#{d.rjust(2, '0')}")
#   end
#
#   def us_date_to_iso_if_needed
#     dup.us_date_to_iso_if_needed!
#   end
#
#   def us_date_to_iso_if_needed!
#     if self =~ /\d+\/\d+\/\d+/
#       us_date_to_iso!
#     else
#       self
#     end
#   end
#
#   private
#     def is_time_interval?
#       !!(self =~ /\d+:\d+:\d+/)
#     end
#
#     def format_aussie_phone_six!
#       if self =~ /^\+61/
#         delete_prefix! "+61"
#         strip!
#         prepend "0" unless self[0] == "0"
#         phone_format!
#         delete_prefix! "0"
#         prepend "+61 "
#       end
#       strip!
#     end
#
#     def format_aussie_phone_four!
#       sub!(/(\d{4})?(\d{3})?/, '\1 \2 ')
#       sub!(/\s+/, ' ')
#       strip!
#     end
#
#     def format_aussie_phone_other!
#       sub!(/(\d{2})?(\d{4})?/, '\1 \2 ')
#       sub!(/\s+/, ' ')
#       strip!
#     end
#
#     def format_us_phone!
#       return self if length < 4
#       sub!(/(\d{3})?(\d{3})?/, '\1-\2-')
#       sub!('--', '-')
#     end
#
#     def strip_phone_prefix!
#       if self =~ /^\+[^1]/
#         gsub!(/[^+0-9]/, '')
#       else
#         gsub!(/^\+?1|[^0-9]/, '')
#         slice!(10..-1)
#       end
#     end
# end
