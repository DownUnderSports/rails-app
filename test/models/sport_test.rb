require 'test_helper'

class SportTest < ActiveSupport::TestCase
  def valid_attributes
    {
      abbr_gendered: "GO",
      full_gendered: "Get Out",
      abbr: "GO",
      full: "Get Out",
      is_numbered: true,
      data: {}
    }
  end

  def assert_database_not_null_constraint(attribute, **opts)
    super Sport, attribute, **opts
  end

  def assert_database_unique_constraint(*attributes)
    values = {}
    Array(attributes).flatten.each do |attr|
      values[attr.to_sym] = sport_fixtures(:gtl).__send__(attr)
    end
    super Sport, **values
  end

  test 'valid sport' do
    sport = Sport.new(valid_attributes)
    assert sport.valid?

    # no optional columns
  end

  test 'invalid sport without abbr' do
    sport = Sport.new(attributes_without :abbr)
    refute sport.valid?, 'sport is valid without abbr'
    assert_not_nil sport.errors[:abbr]
    assert_equal [ "can't be blank" ], sport.errors[:abbr]

    assert_database_not_null_constraint :abbr
  end

  test 'invalid sport without full' do
    sport = Sport.new(attributes_without :full)
    refute sport.valid?, 'sport is valid without full'
    assert_not_nil sport.errors[:full]
    assert_equal [ "can't be blank" ], sport.errors[:full]

    assert_database_not_null_constraint :full
  end

  test 'invalid sport without abbr_gendered' do
    sport = Sport.new(attributes_without :abbr_gendered)
    refute sport.valid?, 'sport is valid without abbr_gendered'
    assert_not_nil sport.errors[:abbr_gendered]
    assert_equal [ "can't be blank" ], sport.errors[:abbr_gendered]

    assert_database_not_null_constraint :abbr_gendered
  end

  test 'invalid sport with reused abbr_gendered' do
    sport = Sport.new(valid_attributes.merge(abbr_gendered: sport_fixtures(:anything).abbr_gendered))
    refute sport.valid?, 'sport is valid with an abbr_gendered already in use'
    assert_not_nil sport.errors[:abbr_gendered]
    assert_equal [ "has already been taken" ], sport.errors[:abbr_gendered]

    assert_database_unique_constraint :abbr_gendered
  end

  test 'invalid sport without full_gendered' do
    sport = Sport.new(attributes_without :full_gendered)
    refute sport.valid?, 'sport is valid without full_gendered'
    assert_not_nil sport.errors[:full_gendered]
    assert_equal [ "can't be blank" ], sport.errors[:full_gendered]

    assert_database_not_null_constraint :full_gendered
  end

  test 'invalid sport with reused full_gendered' do
    sport = Sport.new(valid_attributes.merge(full_gendered: sport_fixtures(:anything).full_gendered))
    refute sport.valid?, 'sport is valid with a full_gendered already in use'
    assert_not_nil sport.errors[:full_gendered]
    assert_equal [ "has already been taken" ], sport.errors[:full_gendered]

    assert_database_unique_constraint :full_gendered
  end

  test 'is_numbered is never null' do
    sport = Sport.new({ abbr_gendered: "NU", full_gendered: "Is Numbered", abbr: "NU", full: "Is Numbered" })

    assert_equal false, sport.is_numbered

    sport.is_numbered = nil
    refute_nil sport.is_numbered
    assert_equal false, sport.is_numbered

    assert_database_not_null_constraint :is_numbered, force: true
    assert_nil_attr_raises Sport.first, :is_numbered
  end

  test 'data uses a hash with indifferent access' do
    sport = Sport.new
    assert_instance_of ActiveSupport::HashWithIndifferentAccess, sport.data
    [
      nil,
      "{}",
      {},
      {}.with_indifferent_access
    ].each do |value|
      sport.data = value
      assert_instance_of ActiveSupport::HashWithIndifferentAccess, sport.data
    end

    mixed = { test: :symbol, "string" => "string", 1 => 1, 1.0 => 1.0, "d" => BigDecimal("0.1") / 1000000000 }

    sport.data = mixed
    assert_equal IndifferentJsonb::Type.new.cast(mixed), sport.data

    mixed.each do |k, v|
      if k.is_a?(Numeric)
        assert_nil sport.data[k]
      else
        assert_equal v.as_json, sport.data[k.to_sym]
      end
      assert_equal v.as_json, sport.data[k.to_s]
    end
  end
end
