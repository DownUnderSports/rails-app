require "test_helper"

class CountryAttributesTest < ActiveSupport::TestCase
  def valid_attributes
    {
      alpha_2: "ZZ",
      alpha_3: "ZZZ",
      numeric: "900",
      short:   "Testable",
      name:    "Testable, the Republic of"
    }
  end

  def assert_database_check_constraint(attribute, value, **opts)
    super Country, attribute, value, **opts
  end

  def assert_database_not_null_constraint(attribute, **opts)
    super Country, attribute, **opts
  end

  def assert_database_unique_constraint(*attributes, **opts)
    Array(attributes).flatten.each do |attr|
      opts[attr.to_sym] = country_fixtures(:one).__send__(attr)
    end
    super Country, **opts
  end

  test "valid country" do
    country = Country.new(valid_attributes)
    assert country.valid?

    # no optional columns
  end

  [
    [ :alpha_2, "AAA", 2, %w[ A AAA .A A.A 0A ] ],
    [ :alpha_3, "AA",  3, %w[ A AA AAAA .AA AA.A 0AA ] ],
    [ :numeric, "01",  3, %w[ 0 00 9999 A99 0.0 0A9 ] ],
  ].each do |attr, bad_val, length, checks|
    test "invalid country without #{attr}" do
      country = Country.new(attributes_without attr)
      refute country.valid?, "country is valid without #{attr}"
      refute_nil country.errors[attr]
      assert_includes country.errors[attr], "can't be blank"

      assert_database_not_null_constraint attr
    end

    test "invalid country with invalid #{attr}" do
      country = Country.new(valid_attributes.merge(attr => bad_val))
      refute country.valid?, "country is valid with invalid #{attr}"
      refute_nil country.errors[attr]
      assert_includes country.errors[attr], "must be #{length} characters"

      country.errors.clear
      country.__send__(:"#{attr}=", "." * length)
      refute country.valid?, "country is valid with invalid #{attr}"
      refute_nil country.errors[attr]
      assert_includes country.errors[attr], "must be only #{attr == :numeric ? "numbers" : "letters"}"

      checks.each {|v| assert_database_check_constraint attr, v }
    end

    test "invalid country with reused #{attr}" do
      country = Country.new(valid_attributes.merge(attr => country_fixtures(:one).__send__(attr)))
      refute country.valid?, "country is valid with #{attr} already in use"
      refute_nil country.errors[attr]
      assert_includes country.errors[attr], "has already been taken"

      assert_database_unique_constraint attr
    end
  end

  [
    :short,
    :name,
  ].each do |attr|
    test "invalid country without #{attr}" do
      country = Country.new(attributes_without attr)
      refute country.valid?, "country is valid without #{attr}"
      refute_nil country.errors[attr]
      assert_includes country.errors[attr], "can't be blank"

      assert_database_not_null_constraint attr
    end

    test "invalid country with reused #{attr}" do
      country = Country.new(valid_attributes.merge(attr => country_fixtures(:one).__send__(attr)))
      refute country.valid?, "country is valid with #{attr} already in use"
      refute_nil country.errors[attr]
      assert_includes country.errors[attr], "has already been taken"

      assert_database_unique_constraint attr
    end
  end
end
