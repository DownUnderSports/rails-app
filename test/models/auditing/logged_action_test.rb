require 'test_helper'

class Auditing::LoggedActionTest < ActiveSupport::TestCase
  test "it connects to the logged_actions view" do
    assert Auditing::LoggedAction.table_name_has_schema?
    assert_equal "auditing", Auditing::LoggedAction.table_schema
    assert_equal "auditing.logged_actions_view", Auditing::LoggedAction.table_name
  end

  test "it belongs to an audited record" do
    reflection = Auditing::LoggedAction.reflect_on_association :audited
    refute_nil reflection
    assert_equal reflection.name, :audited
    assert reflection.options[:polymorphic]
    assert reflection.options[:optional]
    assert_equal reflection.options[:primary_type], :table_name_with_schema
    assert_equal reflection.options[:foreign_key], :row_id
    assert_equal reflection.options[:foreign_type], :table_name
  end

  test "#action must be one of ACTIONS enum" do
    m = Auditing::LoggedAction.new
    ("A".."Z").each do |letter|
      if Auditing::LoggedAction::ACTIONS[letter]
        assert_nothing_raised { m.action = letter }
      else
        assert_raises(ArgumentError) { m.action = letter }
      end
    end
  end

  test "#changed_columns returns a sorted string of all changed fields" do
    sample_fields = 5.times.map {|i| "test_#{i}" }.shuffle
    m = Auditing::LoggedAction.new(changed_fields: sample_fields.to_db_enum)
    assert_equal sample_fields.sort.join(', '), m.changed_columns
  end

  test "#action_type returns the readable form of the logged action" do
    m = Auditing::LoggedAction.new
    %w[ D I U T A ].each do |k|
      m.action = k
      assert_equal Auditing::LoggedAction::ACTIONS[k], m.action_type
    end
  end
end
