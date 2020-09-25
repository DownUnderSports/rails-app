module NeverNilArray
  def deserialize(value)
    super(value || []) rescue []
  end

  def cast(value)
    super(value || []) rescue []
  end

  def serialize(value)
    super(value || []) rescue []
  end

  def changed_in_place?(raw_old_value, new_value)
    deserialize(raw_old_value) != cast(new_value)
  end
end
