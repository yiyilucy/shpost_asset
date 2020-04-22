class ChangeUserToLowValueConsumptionInventoryDetails < ActiveRecord::Migration
  def up
    rename_column :lvc_inventory_details, :user, :use_user
  end

  def down
    rename_column :lvc_inventory_details, :use_user, :user
  end
end
