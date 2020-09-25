require "test_helper"

class AddressAttributesTest < ActiveSupport::TestCase
  def valid_attributes
    {
      country_id: country_fixtures(:one).id,
      postal_code: "59808",
      region: state_fixtures(:one).abbr,
      city: "Missoula",
      delivery: "PO Box 266",
      backup: "3555 Mulan Rd",
      verified_for: [ "USPS" ],
      rejected_for: [ "UPS", "FedEx" ]
    }
  end

  def assert_database_check_constraint(attribute, value, **opts)
    super Address, attribute, value, **opts
  end

  def assert_database_not_null_constraint(attribute, **opts)
    super Address, attribute, **opts
  end

  def assert_database_unique_constraint(*attributes)
    values = {}
    Array(attributes).flatten.each do |attr|
      values[attr.to_sym] = address_fixtures(:one).__send__(attr)
    end
    super Address, **values
  end

  test "valid address" do
    address = Address.new(valid_attributes)
    assert address.valid?

    # optional columns
    [
      :postal_code,
      :region,
      :city,
      :delivery,
      :backup,
    ].each do |attr|
      assert address.respond_to?(attr)
      assert address.respond_to?(:"#{attr}=")
      assert address.valid?

      address.__send__ :"#{attr}=", nil

      assert address.valid?
    end
  end

  test "invalid address without country" do
    address = Address.new(attributes_without :country_id)

    refute address.valid?, "address is valid without country"

    refute_nil address.errors[:country]
    assert_includes address.errors[:country], "must exist"

    assert_database_not_null_constraint :country_id
  end

  %i[
    verified_for
    rejected_for
  ].each do |attr|
    test "#{attr} is never null" do
      address = Address.new(attributes_without attr)

      assert_equal [], address.__send__(attr)

      address.__send__(:"#{attr}=", nil)

      refute_nil address.__send__(attr)
      assert_equal [], address.__send__(attr)

      assert_database_not_null_constraint attr, force: true
      assert_nil_attr_raises Address.first, attr
    end
  end
end
