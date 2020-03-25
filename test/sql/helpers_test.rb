require 'test_helper'

class HelpersTest < ActiveSupport::TestCase
  test "temp_table_exists function exists" do
    assert FunctionsInDB.
      where(proname: "temp_table_exists").
      where("pronamespace = 'public'::regnamespace::oid").
      exists?
  end

  test "hash_password function exists" do
    assert FunctionsInDB.
      where(proname: "hash_password").
      where("pronamespace = 'public'::regnamespace::oid").
      exists?
  end

  test "validate_email function exists" do
    assert FunctionsInDB.
      where(proname: "validate_email").
      where("pronamespace = 'public'::regnamespace::oid").
      exists?
  end

  test "valid_email_trigger function exists" do
    assert FunctionsInDB.
      where(proname: "valid_email_trigger").
      where("pronamespace = 'public'::regnamespace::oid").
      exists?
  end

  test "unique_random_string function exists" do
    assert FunctionsInDB.
      where(proname: "unique_random_string").
      where("pronamespace = 'public'::regnamespace::oid").
      exists?
  end
end
