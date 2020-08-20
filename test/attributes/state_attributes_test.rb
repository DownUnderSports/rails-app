require 'test_helper'

class StateAttributesTest < ActiveSupport::TestCase
  def valid_attributes
    {
      abbr: "YY",
      full: "Yo Yo",
      data: {}
    }
  end

  def assert_database_check_constraint(attribute, value, **opts)
    super State, attribute, value, **opts
  end

  def assert_database_not_null_constraint(attribute, **opts)
    super State, attribute, **opts
  end

  def assert_database_unique_constraint(*attributes)
    values = {}
    Array(attributes).flatten.each do |attr|
      values[attr.to_sym] = state_fixtures(:one).__send__(attr)
    end
    super State, **values
  end

  test 'valid state' do
    state = State.new(valid_attributes)
    assert state.valid?

    # no optional columns
  end

  test 'invalid state without abbr' do
    state = State.new(attributes_without :abbr)
    refute state.valid?, 'state is valid without abbr'
    assert_not_nil state.errors[:abbr]
    assert_includes state.errors[:abbr], "can't be blank"

    assert_database_not_null_constraint :abbr
  end

  test 'invalid state with invalid abbr' do
    state = State.new(valid_attributes.merge(abbr: "AAA"))
    refute state.valid?, 'state is valid with invalid abbr'
    assert_not_nil state.errors[:abbr]
    assert_includes state.errors[:abbr], "must be 2 characters"

    state.errors.clear
    state.abbr = ".."
    refute state.valid?, 'state is valid with invalid abbr'
    assert_not_nil state.errors[:abbr]
    assert_includes state.errors[:abbr], "must be only letters or numbers"

    %w[
      A
      AAA
      .A
      A.A
    ].each {|v| assert_database_check_constraint :abbr, v }
  end

  test 'invalid state with reused abbr' do
    state = State.new(valid_attributes.merge(abbr: state_fixtures(:one).abbr))
    refute state.valid?, 'state is valid with an abbr already in use'
    assert_not_nil state.errors[:abbr]
    assert_equal [ "has already been taken" ], state.errors[:abbr]

    assert_database_unique_constraint :abbr
  end

  test 'invalid state without full' do
    state = State.new(attributes_without :full)
    refute state.valid?, 'state is valid without full'
    assert_not_nil state.errors[:full]
    assert_equal [ "can't be blank" ], state.errors[:full]

    assert_database_not_null_constraint :full
  end

  test 'invalid state with reused full' do
    state = State.new(valid_attributes.merge(full: state_fixtures(:one).full))
    refute state.valid?, 'state is valid with a full already in use'
    assert_not_nil state.errors[:full]
    assert_equal [ "has already been taken" ], state.errors[:full]

    assert_database_unique_constraint :full
  end

  test 'data uses a hash with indifferent access' do
    assert_has_indifferent_hash State.new, :data
  end
end
