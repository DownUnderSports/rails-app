require "test_helper"

class AddressUSAAttributesTest < ActiveSupport::TestCase
  def valid_attributes
    {
      country_id: country_fixtures(:one).id,
      postal_code: "59808-1234",
      region: state_fixtures(:one).abbr,
      city: "Missoula",
      delivery: "PO Box 266",
      backup: "3555 Mulan Rd",
      verified_for: [ "USPS" ],
      rejected_for: [ "UPS", "FedEx" ]
    }
  end

  test "valid USA address" do
    address = Address::USA.new(valid_attributes)
    assert address.valid?, "Valid USA address invalid: #{address.errors.full_messages}"

    address.postal_code = "1-1234"
    address.valid?
    assert address.valid?

    # optional columns
    [
      :backup,
    ].each do |attr|
      assert address.respond_to?(attr)
      assert address.respond_to?(:"#{attr}=")
      assert address.valid?

      address.__send__ :"#{attr}=", nil

      assert address.valid?
    end
  end

  test "invalid USA address without country" do
    address = Address::USA.new(attributes_without :country_id)

    refute address.valid?, "USA address is valid without country"

    refute_nil address.errors[:country]
    assert_includes address.errors[:country], "must exist"
  end

  test "invalid USA address without postal_code" do
    address = Address::USA.new(attributes_without :postal_code)

    refute address.valid?, "USA address is valid without postal_code"

    refute_nil address.errors[:postal_code]
    assert_includes address.errors[:postal_code], "can't be blank"
  end

  test "invalid USA address with invalid postal_code" do
    address = Address::USA.new(valid_attributes)

    [
      "1-1",
      "AAAAA",
      "A1234",
      "11111-1"
    ].each do |v|
      address.postal_code = v
      refute address.valid?, "USA address is valid with invalid postal_code"

      refute_nil address.errors[:postal_code]
      assert_includes address.errors[:postal_code], "must be a valid US Zip Code"
    end

  end

  test "invalid USA address without region" do
    address = Address::USA.new attributes_without :region

    refute address.valid?, "USA address is valid without region"

    refute_nil address.errors[:region]
    assert_includes address.errors[:region], "can't be blank"
  end

  test "invalid USA address with an invalid region" do
    address = Address::USA.new valid_attributes

    [
      "00",
      "ZE",
      "Montanas"
    ].each do |v|
      address.region = v

      refute address.valid?, "USA address is valid with an invalid region: #{v.inspect}"

      refute_nil address.errors[:region]
      assert_includes address.errors[:region], "must be a 2 letter US State"
    end
  end

  test "invalid USA address without city" do
    address = Address::USA.new(attributes_without :city)

    refute address.valid?, "USA address is valid without city"

    refute_nil address.errors[:city]
    assert_includes address.errors[:city], "can't be blank"
  end

  test "invalid USA address without delivery" do
    address = Address::USA.new(attributes_without :delivery)

    refute address.valid?, "USA address is valid without delivery"

    refute_nil address.errors[:delivery]
    assert_includes address.errors[:delivery], "can't be blank"
  end

  %i[
    verified_for
    rejected_for
  ].each do |attr|
    test "#{attr} is never null" do
      address = Address::USA.new(attributes_without attr)

      assert_equal [], address.__send__(attr)

      address.__send__(:"#{attr}=", nil)

      refute_nil address.__send__(attr)
      assert_equal [], address.__send__(attr)
    end
  end
end
