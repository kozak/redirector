class AddOwnerToRedirectRules < ActiveRecord::Migration
  def change
    add_column :redirect_rules, :owner_id, :integer, default: nil
    add_column :redirect_rules, :owner_type, :string, default: nil
    add_index :redirect_rules, [:owner_id, :owner_type]
  end
end
