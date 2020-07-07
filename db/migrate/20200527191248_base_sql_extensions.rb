class BaseSqlExtensions < ActiveRecord::Migration[6.0]
  def up
    enable_extension :pg_trgm
    enable_extension :btree_gin
    enable_extension :pgcrypto
    enable_extension :hstore
    enable_extension :citext
  end
end
