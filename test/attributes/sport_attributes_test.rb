require "test_helper"

class SportAttributesTest < ActiveSupport::TestCase
  def valid_attributes
    {
      abbr_gendered: "GO",
      name_gendered: "Get Out",
      abbr: "GO",
      name: "Get Out",
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

  test "valid sport" do
    sport = Sport.new(valid_attributes)
    assert sport.valid?

    # no optional columns
  end

  test "invalid sport without abbr" do
    sport = Sport.new(attributes_without :abbr)
    refute sport.valid?, "sport is valid without abbr"
    refute_nil sport.errors[:abbr]
    assert_equal [ "can't be blank" ], sport.errors[:abbr]

    assert_database_not_null_constraint :abbr
  end

  test "invalid sport without name" do
    sport = Sport.new(attributes_without :name)
    refute sport.valid?, "sport is valid without name"
    refute_nil sport.errors[:name]
    assert_equal [ "can't be blank" ], sport.errors[:name]

    assert_database_not_null_constraint :name
  end

  test "invalid sport without abbr_gendered" do
    sport = Sport.new(attributes_without :abbr_gendered)
    refute sport.valid?, "sport is valid without abbr_gendered"
    refute_nil sport.errors[:abbr_gendered]
    assert_equal [ "can't be blank" ], sport.errors[:abbr_gendered]

    assert_database_not_null_constraint :abbr_gendered
  end

  test "invalid sport with reused abbr_gendered" do
    sport = Sport.new(valid_attributes.merge(abbr_gendered: sport_fixtures(:anything).abbr_gendered))
    refute sport.valid?, "sport is valid with an abbr_gendered already in use"
    refute_nil sport.errors[:abbr_gendered]
    assert_equal [ "has already been taken" ], sport.errors[:abbr_gendered]

    assert_database_unique_constraint :abbr_gendered
  end

  test "invalid sport without name_gendered" do
    sport = Sport.new(attributes_without :name_gendered)
    refute sport.valid?, "sport is valid without name_gendered"
    refute_nil sport.errors[:name_gendered]
    assert_equal [ "can't be blank" ], sport.errors[:name_gendered]

    assert_database_not_null_constraint :name_gendered
  end

  test "invalid sport with reused name_gendered" do
    sport = Sport.new(valid_attributes.merge(name_gendered: sport_fixtures(:anything).name_gendered))
    refute sport.valid?, "sport is valid with a name_gendered already in use"
    refute_nil sport.errors[:name_gendered]
    assert_equal [ "has already been taken" ], sport.errors[:name_gendered]

    assert_database_unique_constraint :name_gendered
  end

  test "is_numbered is never null" do
    sport = Sport.new({ abbr_gendered: "NU", name_gendered: "Is Numbered", abbr: "NU", name: "Is Numbered" })

    assert_equal false, sport.is_numbered

    sport.is_numbered = nil
    refute_nil sport.is_numbered
    assert_equal false, sport.is_numbered

    assert_database_not_null_constraint :is_numbered, force: true
    assert_nil_attr_raises Sport.first, :is_numbered
  end

  test "data uses a hash with indifferent access" do
    assert_has_indifferent_hash Sport.new, :data
  end
end
