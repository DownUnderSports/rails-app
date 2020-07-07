module IndifferentJsonb
  class Type < ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Jsonb
  end

  def deserialize(value)
    return value if value.is_a?(ActiveSupport::HashWithIndifferentAccess)

    super(value || {}).with_indifferent_access
  end

  def cast(value)
    value = (ActiveSupport::JSON.decode(value) rescue {}) if value.is_a?(String)

    super(value || {}).with_indifferent_access
  end

  def serialize(value)
    super(value || {})
  end

  def changed_in_place?(raw_old_value, new_value)
    deserialize(raw_old_value) != cast(new_value)
  end
end
