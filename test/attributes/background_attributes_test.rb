require "test_helper"

class BackgroundAttributesTest < ActiveSupport::TestCase
  def valid_attributes
    {
      person_id: person_fixtures(:athlete).id,
      sport_id: sport_fixtures(:anything).id,
      category: "athlete",
      year: Date.today.year,
      main: false,
      data: {}
    }
  end

  def assert_database_not_null_constraint(attribute, **opts)
    super Background, attribute, **opts
  end

  def assert_database_unique_constraint(*attributes, **opts)
    Array(attributes).flatten.each do |attr|
      opts[attr.to_sym] = background_fixtures(:athlete_gtl).__send__(attr)
    end
    super Background, **opts
  end

  test "valid background" do
    background = Background.new(valid_attributes)
    assert background.valid?

    # optional columns
    [
      :sport_id,
      :year,
    ].each do |attr|
      assert background.respond_to?(attr)
      assert background.respond_to?(:"#{attr}=")
      assert background.valid?

      background.__send__ :"#{attr}=", nil

      assert background.valid?
    end
  end

  test "invalid background without category" do
    background = Background.new(attributes_without :category)
    refute background.valid?, "background is valid without category"
    refute_nil background.errors[:category]
    assert_equal [ "can't be blank" ], background.errors[:category]

    assert_database_not_null_constraint :category
  end

  test "invalid background with invalid category" do
    background = Background.new(valid_attributes.merge(category: "asdf"))
    refute background.valid?, "background is valid with invalid category"
    refute_nil background.errors[:category]
    assert_equal [ "is not recognized" ], background.errors[:category]
  end

  test "invalid background without person" do
    background = Background.new(attributes_without :person_id)
    refute background.valid?, "background is valid without person"
    refute_nil background.errors[:person]
    assert_includes background.errors[:person], "must exist"

    assert_database_not_null_constraint :person_id
  end

  test "invalid background with reused person|sport|category|year combo" do
    reused = background_fixtures(:athlete_gtl)
    attrs = valid_attributes.dup
    uniq = [
      [:person_id, person_fixtures(:staff).id],
      [:sport_id, sport_fixtures(:anything).id],
      [:category, "coach"],
      [:year, 2021]
    ]
    uniq.each {|attr,_| attrs[attr] = reused.__send__ attr }

    background = Background.new(attrs)

    refute background.valid?, "background is valid with a person|sport|category|year combo already in use"

    refute_nil background.errors[:base]
    assert_includes background.errors[:base], "Background already exists"

    uniq.each do |attr, v|
      background.__send__ "#{attr}=", v
      assert background.valid?, "background invalid with uniq combo"
      background.__send__ "#{attr}=", reused.__send__(attr)
    end

    assert_database_unique_constraint uniq.map(&:first), index_name: "unique_background_index", complex: true
  end

  test "main is never null" do
    background = Background.new(attributes_without :main)

    assert_equal false, background.main

    background.main = nil
    refute_nil background.main
    assert_equal false, background.main

    assert_database_not_null_constraint :main, force: true
    assert_nil_attr_raises Background.first, :main
  end

  test "invalid background if \"main\" already exists" do
    background = background_fixtures(:athlete_btl)

    assert background.valid?, "background is already invalid"

    background.main = true

    refute background.valid?, "second \"main\" background valid"

    refute_nil background.errors[:main]
    assert_includes background.errors[:main], "only allowed for one background"

    assert_database_unique_constraint :person_id, :main, partial: :person_id
  end

  test "data uses a hash with indifferent access" do
    assert_has_indifferent_hash Background.new, :data
  end
end
