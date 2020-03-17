require 'test_helper'

class AuditingSchemaTest < ActiveSupport::TestCase
  test "auditing.logged_actions table exists" do
    assert TablesInDB.
      where(table_name: "logged_actions", table_schema: "auditing").
      exists?
  end

  test "auditing.logged_actions_view view exists" do
    assert TablesInDB.
      where(table_name: "logged_actions_view", table_schema: "auditing").
      exists?
  end

  test "auditing.table_list view exists" do
    assert TablesInDB.
      where(table_name: "table_list", table_schema: "auditing").
      exists?
  end

  test "temp_table_info type exists" do
    assert TypesInDB.
      where(typname: "temp_table_info").
      exists?
  end

  test "auditing.get_table_information function exists" do
    assert FunctionsInDB.
      where(proname: "get_table_information").
      where("pronamespace = 'auditing'::regnamespace::oid").
      exists?
  end

  test "auditing.get_primary_key_column function exists" do
    assert FunctionsInDB.
      where(proname: "get_primary_key_column").
      where("pronamespace = 'auditing'::regnamespace::oid").
      exists?
  end

  test "auditing.skip_logged_actions_main function exists" do
    assert FunctionsInDB.
      where(proname: "skip_logged_actions_main").
      where("pronamespace = 'auditing'::regnamespace::oid").
      exists?
  end

  test "auditing.logged_actions_partition function exists" do
    assert FunctionsInDB.
      where(proname: "logged_actions_partition").
      where("pronamespace = 'auditing'::regnamespace::oid").
      exists?
  end

  test "auditing.if_modified_func function exists" do
    assert FunctionsInDB.
      where(proname: "if_modified_func").
      where("pronamespace = 'auditing'::regnamespace::oid").
      exists?
  end

  test "auditing.audit_table function exists" do
    query = FunctionsInDB.
      where(proname: "audit_table").
      where("pronamespace = 'auditing'::regnamespace::oid")
    arg_names = %w[ target_table audit_rows audit_query_text ignored_cols ]

    assert query.exists?
    assert query.size == 3

    assert query.all.each do |func|
      func.proargnames.all? {|arg| arg.in? arg_names}
    end
  end
end
