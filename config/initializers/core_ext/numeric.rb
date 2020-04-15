# frozen_string_literal: true

class Numeric
  def min_max(min, max)
    coerced_value [
      max.coerced_value([ min.coerced_value(self), min ].max),
      max
    ].min
  end

  def coerced_value(value)
    coerce(value)[0]
  end
end
