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
  def self.stub_instances(
                          name,
                          val_or_callable = nil,
                          keep_self: false,
                          stub_name: nil,
                          pass_sub_block: false,
                          &block
                        )

    new_name = stub_name.presence || "__minitest_any_instance_stub__#{name}"

    owns_method = instance_method(name).owner == self
    class_eval do
      alias_method new_name, name if owns_method

      define_method(name) do |*args, **opts, &sub_block|
        if val_or_callable.respond_to? :call then
          if keep_self
            if pass_sub_block && sub_block.present?
              instance_exec do
                val_or_callable.bind(self).call *args, **opts, &sub_block
              end
            else
              instance_exec(*args, **opts,  &val_or_callable)
            end
          else
            val_or_callable.call(*args, **opts)
          end
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

class Proc #:nodoc:
  def bind(object)
    block = self
    object.class_eval do
      method_name = :__bind_proc__
      method = nil
      Thread.exclusive do
        method_already_exists =
          object.respond_to?(method_name) &&
          instance_method(method_name).owner == self

        old_method = instance_method(method_name) if method_already_exists

        define_method(method_name, &block)
        method = instance_method(method_name)
        remove_method(method_name)

        define_method(method_name, old_method) if method_already_exists
      end
    end.bind(object)
  end
end
