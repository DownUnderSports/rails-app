class StreamJSONDeflator
  def self.nil_to_s(v)
    v.nil? ? '' : v
  end

  def initialize(enum, is_array = false)
    @concat = is_array === 'concat'
    @is_array = !@concat && Boolean.parse(is_array)
    @enum = enum
    @deflator = Zlib::Deflate.new
    @depth = 1
    y << @deflator.deflate(@is_array ? '[' : '{') unless @concat
  end

  def y
    @enum
  end

  def stream(comma, k, v, exact = false)
    @depth -= 1 if v.to_s =~ /^\s*[\}\]]/
    y << @deflator.deflate("#{comma ? ',' : ''}\n#{'  ' * @depth}#{k ? "\"#{k}\":" : ''}#{exact ? v : get_json(v)}", Zlib::SYNC_FLUSH)
    @depth += 1 if v.to_s =~ /[\{\[]\s*$/
  end

  def close
    y << @deflator.deflate(@concat ? "\n" : "\n#{@is_array ? ']' : '}'}", Zlib::FINISH)
  end

  def get_json(v)
    if v =~ /!!-->>/
      @setting_options = true
    end
    if @setting_options
      if v =~ /<<--!!/
        @setting_options = false
        v = v.split('<<--!!')
        return "#{v[0]}<<--!!#{get_json(v[1])}"
      end

      return v
    end
    return v if (v =~ /[{}\[\]]|--JSON--([A-Z]+--)*|!!-->>|<<--!!/)
    (v.is_a?(Hash) || v.is_a?(Array) || v.is_a?(ActiveRecord::Base)) ? JSON.pretty_generate(v.as_json, depth: @depth) : nil_to_s(v).to_json
  end

  def nil_to_s(v)
    self.class.nil_to_s(v)
  end
end
