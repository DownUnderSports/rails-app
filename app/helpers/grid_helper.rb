module GridHelper
  SIZES = %i[ base phone largephone tablet desktop largedesktop ].freeze
  def cell_tag(tag_name = :div, **opts, &block)
    content_tag tag_name, block_given? ? capture(&block) : '', class: cell_classes(**opts)
  end

  def cell_span(value, size = nil)
    value.presence \
    && "mdc-layout-grid__cell--span-#{value}#{cell_suffix(size)}"
  end

  def cell_order(value, size = nil)
    value.presence \
    && "mdc-layout-grid__cell--order-#{value}#{cell_suffix(size)}"
  end

  private
    def cell_classes(**opts)
      classes = %w[ mdc-layout-grid__cell ]
      classes << opts[:class] if opts[:class].present?
      prev_span = prev_order = nil
      incremental = boolean_unless_symbol(opts[:incremental])

      SIZES.each do |size|
        value = opts[size]
        incremental = true if size == opts[:incremental]

        span, order = parse_cell_opt(value)
        if incremental
          span ||= prev_span
          order ||= prev_order
        end
        prev_span, prev_order = span, order

        classes |= [ cell_span(span, size), cell_order(order, size) ]
      end

      classes.reject(&:nil?).join(" ")
    end

    def parse_cell_opt(value)
      case value
      when Integer, String
        [ value.presence ]
      when Hash
        [ value[:span].presence, value[:order].presence ]
      else
        []
      end
    end

    def cell_suffix(size)
      size&.to_s&.!=("base") ? "-#{size}" : ""
    end

    def boolean_unless_symbol(value)
      case value
      when Symbol
        false
      else
        CoerceBoolean.from(value)
      end
    end
end
