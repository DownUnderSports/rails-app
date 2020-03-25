# frozen_string_literal: true

class String
  # == Constants ============================================================
  TIME_REGEX = /^\d+:\d+:\d+(?:\.\d+)?$/.freeze

  TR_REPLACE =      "ÀÁÂÃÄÅàáâãäåĀāĂăĄą" \
                    "ÇçĆćĈĉĊċČč" \
                    "ÐðĎďĐđ" \
                    "ÈÉÊËèéêëĒēĔĕĖėĘęĚě" \
                    "ĜĝĞğĠġĢģ" \
                    "ĤĥĦħ" \
                    "ÌÍÎÏìíîïĨĩĪīĬĭĮįİı" \
                    "Ĵĵ" \
                    "Ķķĸ" \
                    "ĹĺĻļĽľĿŀŁł" \
                    "ÑñŃńŅņŇňŉŊŋ" \
                    "ÒÓÔÕÖØòóôõöøŌōŎŏŐő" \
                    "ŔŕŖŗŘř" \
                    "ŚśŜŝŞşŠšȘș" \
                    "ſŢţŤťŦŧȚț" \
                    "ÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲų" \
                    "Ŵŵ" \
                    "ÝýÿŶŷŸ" \
                    "ŹźŻżŽž" \
                    "“‘”’’".freeze

  TR_REPLACE_WITH = "AAAAAAaaaaaaAaAaAa" \
                    "CcCcCcCcCc" \
                    "DdDdDd" \
                    "EEEEeeeeEeEeEeEeEe" \
                    "GgGgGgGg" \
                    "HhHh" \
                    "IIIIiiiiIiIiIiIiIi" \
                    "Jj" \
                    "Kkk" \
                    "LlLlLlLlLl" \
                    "NnNnNnNnnNn" \
                    "OOOOOOooooooOoOoOo" \
                    "RrRrRr" \
                    "SsSsSsSsSss" \
                    "TtTtTtTt" \
                    "UUUUuuuuUuUuUuUuUuUu" \
                    "Ww" \
                    "YyyYyY" \
                    "ZzZzZz" \
                    "\"\'\"\'\'".freeze

  # == Extensions ===========================================================
  redefine_once(:to_i, :og_to_i) do
    begin
      is_time_interval? ? to_d.to_i : og_to_i
    rescue
      og_to_i
    end
  end

  redefine_once(:to_d, :og_to_d) do
    begin
      if is_time_interval?
        self.split(':').
          map { |a| a.to_d }.
          inject(0) {|a, b| a * BigDecimal(60) + b }
      else
        og_to_d
      end
    rescue
      og_to_d
    end
  end

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================
  def self.levenshtein_distance(str1, str2)
    # copied directly from the Gem::Text implementation
    # Returns a value representing the "cost" of transforming str1 into str2

    s = str1
    t = str2
    n = s.length
    m = t.length

    return m if (0 == n)
    return n if (0 == m)

    d = (0..m).to_a
    x = nil

    str1.each_char.each_with_index do |char1,i|
      e = i + 1

      str2.each_char.each_with_index do |char2,j|
        cost = (char1 == char2) ? 0 : 1
        x = min_of_trio(
             d[j + 1] + 1, # insertion
             e + 1,      # deletion
             d[j] + cost # substitution
           )
        d[j] = e
        e = x
      end

      d[m] = x
    end

    return x
  end

  def self.min_of_trio(a, b, c) # :nodoc:
    if a < b && a < c
      a
    elsif b < c
      b
    else
      c
    end
  end

  # == Boolean Methods ======================================================
  def is_time_interval?
    TIME_REGEX.match? self
  end

  # == Instance Methods =====================================================
  def abbr_format
    dup.abbr_format!
  end

  def abbr_format!
    upcase!
    gsub!(/[^A-Z]/, '')
    slice!(3..-1)
    self
  end

  def clean_certificate
    dup.clean_certificate!
  end

  def clean_certificate!
    unescape!
    strip!
    delete_prefix! "-----BEGIN CERTIFICATE-----"
    delete_suffix! "-----END CERTIFICATE-----"
    delete! "\n\s"
    self
  end

  def cleanup
    dup.cleanup!
  end

  def cleanup!
    gsub!(/\s*(?:\r?\n\s*|\s+)/, ' ')
    self
  end

  def cleanup_production
    Rails.env.production? \
      ? cleanup
      : self
  end

  def decrypt_token
    JSON.parse(decrypt_gpg_base64(str.strip))
  end

  def decrypt_token!
    self.replace decrypt_token
  end

  def distance_from(str)
    self.class.levenshtein_distance(self, str)
  end

  def dup
    self + ''
  end

  def dus_id_format
    dup.dus_id_format!
  end

  def dus_id_format!
    upcase!
    gsub!(/[^A-Z]/, '')
    slice!(6..-1)
    self
  end

  def from_b64
    dup.from_b64!
  end

  def from_b64!
    replace(Base64.strict_decode64(self))
    force_encoding 'UTF-8'
    self
  end

  def phone_format
    dup.phone_format!
  end

  def phone_format!
    return '' unless present?

    strip_phone_prefix!

    return self if length < 10

    case self
    when /^\+6/
      format_aussie_phone_six!
    when /^04/
      format_aussie_phone_four!
    when /^0/
      format_aussie_phone_other!
    else
      format_us_phone!
    end

    self
  end

  def print_safe
    dup.print_safe!
  end

  def print_safe!
    tr!(TR_REPLACE, TR_REPLACE_WITH)
    self
  end

  def titleize(name: true, keep_id_suffix: false)
    ActiveSupport::Inflector.titleize(self, name: name, keep_id_suffix: name || keep_id_suffix)
  end

  def to_b64
    dup.to_b64!
  end

  def to_b64!
    replace(Base64.strict_encode64(self))
    force_encoding 'UTF-8'
    self
  end

  def unescape
    CGI.unescape(self)
  end

  def unescape!
    self.replace CGI.unescape(self)
  end

  def us_date_to_iso
    dup.us_date_to_iso!
  end

  def us_date_to_iso!
    m, d, y = self.split('/')
    replace("20#{y.rjust(4, '0')[-2..-1]}-#{m.rjust(2, '0')}-#{d.rjust(2, '0')}")
  end

  def us_date_to_iso_if_needed
    dup.us_date_to_iso_if_needed!
  end

  def us_date_to_iso_if_needed!
    if self =~ /\d+\/\d+\/\d+/
      us_date_to_iso!
    else
      self
    end
  end

  alias :distance :distance_from

  private
    def format_aussie_phone_six!
      if self =~ /^\+61/
        delete_prefix! "+61"
        strip!
        prepend "0" unless self[0] == "0"
        phone_format!
        delete_prefix! "0"
        prepend "+61 "
      end
      strip!
    end

    def format_aussie_phone_four!
      sub!(/(\d{4})?(\d{3})?/, '\1 \2 ')
      sub!(/\s+/, ' ')
      strip!
    end

    def format_aussie_phone_other!
      sub!(/(\d{2})?(\d{4})?/, '\1 \2 ')
      sub!(/\s+/, ' ')
      strip!
    end

    def format_us_phone!
      return self if length < 4
      sub!(/(\d{3})?(\d{3})?/, '\1-\2-')
      sub!('--', '-')
    end

    def strip_phone_prefix!
      if self =~ /^\+[^1]/
        gsub!(/[^+0-9]/, '')
      else
        gsub!(/^\+?1|[^0-9]/, '')
        slice!(10..-1)
      end
    end
end
