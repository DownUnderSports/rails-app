module TestHelper
  module MethodAssertions
    extend ActiveSupport::Concern

    def assert_alias_of(object, original_name, aliased_name)
      assert_equal \
        object.method(original_name).original_name,
        object.method(aliased_name).original_name
    end

    def assert_is_getter(object, mthd, inst_v = nil)
      inst_v ||= :"@#{mthd}"
      original = object.instance_variable_get(inst_v)
      object.instance_variable_set(inst_v, value = "#{rand}.#{Time.now}")
      assert_equal object.instance_variable_get(inst_v), object.__send__(mthd)
      object.instance_variable_set(inst_v, original)
    end

    def assert_is_setter(object, mthd, inst_v = nil)
      inst_v ||= :"@#{mthd.sub("=", '')}"

      original = object.instance_variable_get(inst_v)
      object.instance_variable_set(inst_v, "#{rand}.#{Time.now}")

      val = (block_given? ? yield : "#{rand}.#{Time.now}")

      refute_equal val, object.instance_variable_get(inst_v)

      object.__send__(mthd, val)

      assert_equal val, object.instance_variable_get(inst_v)

      object.instance_variable_set(inst_v, original)
    end

    def assert_is_accessor(object, mthd, inst_v = nil, &block)
      assert_is_getter object, mthd, inst_v
      assert_is_setter object, "#{mthd}=", inst_v, &block
    end

    def assert_calls_method(object, method_to_stub, expected: nil, instances: false)
      given = nil
      skip_input = (expected == :skip_input)
      unless expected.present? || skip_input
        expected = []

        (rand(10) + 1).times do
          expected << rand
        end
      end

      stubbed = (
        skip_input ?
          ( ->(*args, **opts) { given = :called_method } ) :
          ( ->(arg) { given = arg } )
      )

      if instances
        object.stub_instances(method_to_stub, stubbed) do
          yield expected
        end
      else
        object.stub(method_to_stub, stubbed) do
          yield expected
        end
      end

      if skip_input
        assert_equal :called_method, given
      else
        assert_equal expected, given
      end

      expected
    end

    def assert_calls_super(object, method_to_stub, expected: nil, &block)
      assert_calls_method \
        object.class.superclass,
        method_to_stub,
        instances: true,
        expected: expected,
        &block
    end

    def assert_has_indifferent_hash(object, method)
      assert_instance_of ActiveSupport::HashWithIndifferentAccess, object.__send__(method)
      [
        nil,
        "{}",
        {},
        {}.with_indifferent_access
      ].each do |value|
        object.__send__(:"#{method}=", value)
        assert_instance_of ActiveSupport::HashWithIndifferentAccess, object.__send__(method)
      rescue
        puts $!.message
        puts $!.backtrace
        raise
      end

      mixed = { test: :symbol, "string" => "string", 1 => 1, 1.0 => 1.0, "d" => BigDecimal("0.1") / 1000000000 }

      object.__send__(:"#{method}=", mixed)
      assert_equal IndifferentJsonb::Type.new.cast(mixed), object.__send__(method)

      mixed.each do |k, v|
        if k.is_a?(Numeric)
          assert_nil object.__send__(method)[k]
        else
          assert_equal v.as_json, object.__send__(method)[k.to_sym]
        end
        assert_equal v.as_json, object.__send__(method)[k.to_s]
      end
    end
  end
end
