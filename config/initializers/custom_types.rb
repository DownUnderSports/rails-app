Rails.application.reloader.to_prepare do
  # ActiveRecord::Type.register(:indifferent_jsonb, IndifferentJsonb::Type, adapter: :postgresql, override: true)

  ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Jsonb.prepend IndifferentJsonb
  ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.prepend NeverNilArray
  ActiveModel::Type::Boolean.prepend StrictBoolean
end
