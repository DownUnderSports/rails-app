class BlobValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, values)
    unless values.attached?
      record.errors.add(attribute, "is required") unless options[:allow_blank]
    end

    Array(values).each do |value|
      new_errors = validate_blob_size(value.blob, options[:size])

      new_errors << content_type_error unless valid_content_type?(value.blob, options[:type])

      new_errors.uniq.each {|msg| record.errors.add(attribute, msg) }
    end
  end

  private

    def validate_blob_size(blob, checks)
      errors = []
      @size_range = nil

      case checks.presence
      when nil
        return []
      when Range, Array
        @size_range = checks
        if checks.min > blob.byte_size
          errors << min_size_error
        elsif checks.max < blob.byte_size
          errors << max_size_error
        end
      when Hash
        checks = (checks[:min].presence || 0.0)..(checks[:max].presence || Float::INFINITY)
        return validate_blob_size(blob, checks)
      else
        @size_range = 0..checks
        errors << max_size_error if checks < blob.byte_size
      end

      errors
    rescue
      puts $!.message
      puts $!.backtrace
      [ "server setup error" ]
    end

    def valid_content_type?(blob, check)
      return true if check.nil?

      case check
      when Hash
        valid_content_type?(blob, check[:allowed])
      when Regexp
        check.match?(blob.content_type)
      when Array
        check.include?(blob.content_type)
      when Symbol
        blob.public_send("#{check}?")
      else
        check == blob.content_type
      end
    end

    def content_type_error
      (options[:type].is_a?(Hash) && options[:type][:message]).presence \
      || options[:message].presence \
      || "invalid file type"
    end

    def min_size_error
      get_size_message(:min_message) \
      ||  (
            @size_range.present? \
              ? "must be at least #{ ActiveSupport::NumberHelper.number_to_human_size(@size_range.min)}" \
              : "is too small"
          )
    end

    def max_size_error
      get_size_message(:max_message) \
      ||  (
            @size_range.present? \
              ? "cannot be larger than #{ActiveSupport::NumberHelper.number_to_human_size(@size_range.max)}" \
              : "is too large"
          )
    end

    def get_size_message(key)
      (
        options[:size].is_a?(Hash) \
        && (
          options[:size][key].presence \
          || options[:size][:message].presence
        )
      ) || options[:message].presence
    end
end
