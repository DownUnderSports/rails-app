require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  setup do
    initialize_test_address_structure
  end

  teardown do
    unset_test_address_structure
  end

  def initialize_test_address_structure
    unless defined?(Address::COUNTRY_STRUCTURE_TEST)
      Address
      Address.const_set :COUNTRY_STRUCTURE_TEST, define_test_structure_class
    end
  end

  def define_test_structure_class
    Class.new(Address::Structure) {
      validate :always_invalid

      def always_invalid
        self.errors.add(:base, "Structure is always invalid")
      end
    }
  end

  def unset_test_address_structure
    Address.__send__ :remove_const, :COUNTRY_STRUCTURE_TEST
  end

  test "#structure is a getter for @structure" do
    assert_is_getter Address.new, :structure
  end

  test "#structure returns the structure for a given country if available" do
    address = Address.new country: Country.new(alpha_3: "COUNTRY_STRUCTURE_TEST")
    assert_kind_of Address::COUNTRY_STRUCTURE_TEST, address.structure

    Country.all.find_each do |country|
      address = Address.new country: country
      if country.alpha_3 == "USA"
        assert_kind_of Address::USA, address.structure
      elsif Address.const_defined?(country.alpha_3)
        assert_kind_of Address.const_get(country.alpha_3), address.structure
      else
        assert_kind_of Address::Structure, address.structure
      end
    end
  end

  test "initializes its structure on initialize" do
    address = Address.new
    refute_nil address.instance_variable_get(:@structure)
    assert_kind_of Address::Structure, address.instance_variable_get(:@structure)
  end

  test "is invalid with invalid structure" do
    address = Address.new country: Country.new(alpha_3: "COUNTRY_STRUCTURE_TEST")
    refute address.valid?
    assert_includes address.errors[:base], "Structure is always invalid"
  end
end
