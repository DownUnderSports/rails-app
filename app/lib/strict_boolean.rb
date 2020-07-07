module StrictBoolean
  class Type < ActiveModel::Type::Boolean
  end

  def cast(value)
    return false if value.nil?
    super(value)
  end

  private
    def cast_value(value)
      return false if value.nil?
      super(value)
    end
end
