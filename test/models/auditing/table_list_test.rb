require 'test_helper'

class Auditing::TableListTest < ActiveSupport::TestCase
  test "it connects to the audited table_list" do
    assert Auditing::TableList.table_name_has_schema?
    assert_equal "auditing", Auditing::TableList.table_schema
    assert_equal "auditing.table_list", Auditing::TableList.table_name
  end

  test "it lists all audited tables" do
    # assert_equal 0, Auditing::TableList.all.size
    skip "No Audited Models Available"
  end
end
