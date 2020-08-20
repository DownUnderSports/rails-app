class AssociateJsonbInstall < ActiveRecord::Migration[5.0]
  def up
    add_jsonb_foreign_key_function
    add_jsonb_nested_set_function
  end
end
