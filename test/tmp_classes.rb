require 'active_record/connection_adapters/postgresql_adapter'

module Kernel
  private
    alias :og_warn :warn
    def warn(*args)
      opt = args[-1].is_a?(Hash) ? args.pop : {}
      filtered = args.select do |arg|
        arg !~ /^unknown OID (24|194|1034)/
      end
      og_warn(*filtered, opt) if filtered[0]
    end
end


class FunctionsInDB < ApplicationRecord
  self.table_name = "pg_catalog.pg_proc"
end

class PgExtension < ApplicationRecord
  self.primary_key = :oid
  self.table_name = :pg_extension
end

class TablesInDB < ApplicationRecord
  self.table_name = "information_schema.tables"
end

class TypesInDB < ApplicationRecord
  self.table_name = "pg_catalog.pg_type"
end

class BasicObject
  def self.stub_instances(name, val_or_callable = nil, &block)
    new_name = "__minitest_any_instance_stub__#{name}"

    owns_method = instance_method(name).owner == self
    class_eval do
      alias_method new_name, name if owns_method

      define_method(name) do |*args, **opts|
        if val_or_callable.respond_to? :call then
          val_or_callable.call(*args, **opts)
        else
          val_or_callable
        end
      end
    end

    yield
  ensure
    class_eval do
      remove_method name
      if owns_method
        alias_method name, new_name
        remove_method new_name
      end
    end
  end
end
