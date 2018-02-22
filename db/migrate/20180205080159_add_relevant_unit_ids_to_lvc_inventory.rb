class AddRelevantUnitIdsToLvcInventory < ActiveRecord::Migration
  def change
  	add_column :lvc_inventories, :relevant_unit_ids, :string
  end
end
