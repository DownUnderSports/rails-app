require 'test_helper'

class DomainsTest < ActiveSupport::TestCase
  test "exchange_rate_integer type exists" do
    assert TypesInDB.
      where(typname: "exchange_rate_integer").
      exists?
  end

  test "gender type exists" do
    assert TypesInDB.
      where(typname: "gender").
      exists?
  end

  test "money_integer type exists" do
    assert TypesInDB.
      where(typname: "money_integer").
      exists?
  end

  test "three_state type exists" do
    assert TypesInDB.
      where(typname: "three_state").
      exists?
  end
end
