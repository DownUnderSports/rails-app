require "active_record/connection_adapters/postgresql_adapter"
require "active_record/connection_adapters/postgresql/oid/enum"
require "active_record/connection_adapters/postgresql/oid/type_map_initializer"

module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      module OID # :nodoc:
        class Enum < Type::Value
          attr_accessor :value_array, :type_override

          def cast(value)
            value_array ? value_array.find {|v| /^#{v}/i =~ value.to_s } : value.to_s
          end

          def type
            type_override || :enum
          end

          private

            def cast_value(value)
              value_array ? value_array.find {|v| /^#{v}/i =~ value.to_s } : value.to_s
            end
        end
        # This class uses the data from PostgreSQL pg_type table to build
        # the OID -> Type mapping.
        #   - OID is an integer representing the type.
        #   - Type is an OID::Type object.
        # This class has side effects on the +store+ passed during initialization.

        class TypeMapInitializer # :nodoc:
          private
            def register_domain_type(row)
              if (in_reg = check_registry(row['typname']))
                register row['oid'], in_reg
              elsif base_type = @store.lookup(row["typbasetype"].to_i)
                register row["oid"], base_type
              else
                warn "unknown base type (OID: #{row["typbasetype"]}) for domain #{row["typname"]}."
              end
            end

            def register_enum_type(row)
              if (reg_val = check_registry(row['typname'])).is_a?(CustomType)
                register row['oid'], reg_val
              else
                enum_val = OID::Enum.new
                enum_val.value_array = row['enumlabel'][1..-2].split(',').presence
                enum_val.value_array.map!(&:to_i) if enum_val.value_array.all? {|v| v =~ /^[0-9]+$/}

                enum_val.type_override = (reg_val && row['typname'].to_sym).presence

                register row["oid"], enum_val
              end
            end

            def check_registry(name)
              ActiveRecord::Type.registry.lookup(name.to_sym)
            rescue
              nil
            end

        end
      end
    end

    class PostgreSQLAdapter < AbstractAdapter
      private
        alias_method :default_configure_connection, :configure_connection

        # Monkey patch configure_connection because set_limit() must be called on a per-connection basis.
        def configure_connection
          default_config_result = default_configure_connection
          begin
            execute("SET pg_trgm.similarity_threshold = 0.6;")
          rescue ActiveRecord::StatementInvalid
            Rails.logger.warn("pg_trgm extension not enabled yet")
          end
          default_config_result
        end

        def load_additional_types(oids = nil)
          initializer = OID::TypeMapInitializer.new(type_map)

          query = <<-SQL
            SELECT t.oid, t.typname, t.typelem, t.typdelim, t.typinput, r.rngsubtype, t.typtype, t.typbasetype,
                   array_agg(e.enumlabel) as enumlabel
            FROM pg_type as t
            LEFT JOIN pg_range as r ON t.oid = r.rngtypid
            LEFT JOIN pg_catalog.pg_enum as e ON t.oid = e.enumtypid
          SQL

          if oids
            query += "WHERE t.oid::integer IN (%s)" % oids.join(", ")
          else
            query += initializer.query_conditions_for_initial_load
          end

          query += " GROUP BY 1,2,3,4,5,6,7,8"

          execute_and_clear(query, "SCHEMA", []) do |records|
            initializer.run(records)
          end
        end
    end
  end
end
