require 'test_helper'

class ExtensionsTest < ActiveSupport::TestCase
  test "pg_trgm extension is enabled" do
    assert PgExtension.where(extname: 'pg_trgm').exists?
  end

  test "btree_gin extension is enabled" do
    assert PgExtension.where(extname: 'btree_gin').exists?
  end

  test "pgcrypto extension is enabled" do
    assert PgExtension.where(extname: 'pgcrypto').exists?
  end
end
