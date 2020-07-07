require 'test_helper'

class BackgroundTest < ActiveSupport::TestCase
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

  test 'valid background' do
    background = Background.new(valid_attributes)
    assert background.valid?

    # optional columns
    [
      :sport_id,
      :category,
      :year,
    ].each do |attr|
      assert background.respond_to?(attr)
      assert background.respond_to?(:"#{attr}=")
      assert background.valid?

      background.__send__ :"#{attr}=", nil

      assert background.valid?
    end
  end

  test 'invalid background without person' do
    background = Background.new(attributes_without :person_id)
    refute background.valid?, 'background is valid without person'
    assert_not_nil background.errors[:person]
    assert_equal [ "must exist" ], background.errors[:person]

    assert_database_not_null_constraint :person_id
  end

  test 'invalid background with reused person|sport|category|year combo' do
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

    refute background.valid?, 'background is valid with a person|sport|category|year combo already in use'

    assert_not_nil background.errors[:base]
    assert_equal [ "Background already exists" ], background.errors[:base]

    uniq.each do |attr, v|
      background.__send__ "#{attr}=", v
      assert background.valid?, "background invalid with uniq combo"
      background.__send__ "#{attr}=", reused.__send__(attr)
    end

    assert_database_unique_constraint uniq.map(&:first), index_name: "unique_background_index", complex: true
  end

  test 'main is never null' do
    background = Background.new(attributes_without :main)

    assert_equal false, background.main

    background.main = nil
    refute_nil background.main
    assert_equal false, background.main

    assert_database_not_null_constraint :main, force: true
    assert_nil_attr_raises Background.first, :main
  end

  test 'invalid background if "main" already exists' do
    background = background_fixtures(:athlete_btl)

    assert background.valid?, 'background is already invalid'

    background.main = true

    refute background.valid?, 'second "main" background valid'

    assert_not_nil background.errors[:main]
    assert_equal [ "only allowed for one background" ], background.errors[:main]

    assert_database_unique_constraint :person_id, :main, partial: :person_id
  end

  test 'data uses a hash with indifferent access' do
    background = Background.new
    assert_instance_of ActiveSupport::HashWithIndifferentAccess, background.data
    [
      nil,
      "{}",
      {},
      {}.with_indifferent_access
    ].each do |value|
      background.data = value
      assert_instance_of ActiveSupport::HashWithIndifferentAccess, background.data
    end

    mixed = { test: :symbol, "string" => "string", 1 => 1, 1.0 => 1.0, "d" => BigDecimal("0.1") / 1000000000 }

    background.data = mixed
    assert_equal IndifferentJsonb::Type.new.cast(mixed), background.data

    mixed.each do |k, v|
      if k.is_a?(Numeric)
        assert_nil background.data[k]
      else
        assert_equal v.as_json, background.data[k.to_sym]
      end
      assert_equal v.as_json, background.data[k.to_s]
    end
  end
end
