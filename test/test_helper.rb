ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/mock'
require_relative './tmp_classes'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  unless CoerceBoolean.from(ENV['SYNC_TEST'])
    parallelize(workers: :number_of_processors)
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

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

  def does_call_method(object, method_to_stub, expected: nil, instances: false)
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

  def does_call_super_method(object, method_to_stub, expected: nil, &block)
    does_call_method \
      object.class.superclass,
      method_to_stub,
      instances: true,
      expected: expected,
      &block
  end

  def assert_alias_of(object, original_name, aliased_name)
    assert_equal \
      object.method(original_name).original_name,
      object.method(aliased_name).original_name
  end

  def assert_hash_equal(expected, given)
    assert_equal expected.keys.sort, given.keys.sort
    (expected.keys | given.keys).map do |k|
      assert_equal expected[k], given[k]
    end
  end

  def valid_attributes
    raise "not implemented"
  end

  def attributes_without(*keys)
    valid_attributes.except(*keys)
  end

  def assert_database_constraint(record, attribute, klass)
    err = assert_raises(klass) do
      record.save(validate: false)
    end

    err
  end

  def assert_database_not_null_constraint(klass, attribute)
    record = klass.new(attributes_without attribute)

    err = assert_database_constraint record, attribute, ActiveRecord::NotNullViolation

    assert_match \
      "null value in column \"#{attribute}\" violates not-null constraint",
      err.message
  end

  def assert_database_unique_constraint(klass, attribute, duplicate)
    record    = klass.new(valid_attributes.merge(attribute => duplicate))
    err       = assert_database_constraint record, attribute, ActiveRecord::RecordNotUnique

    assert_match \
      "duplicate key value violates unique constraint",
      err.message

    assert_match \
      "DETAIL:  Key (#{attribute})=(#{duplicate}) already exists.",
      err.message
  end
end
