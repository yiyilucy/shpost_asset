class RenameRelevantDepartmentToFixedAssetInventoryDetail < ActiveRecord::Migration
  def change
  	rename_column :fixed_asset_inventory_details, :relevant_department, :relevant_unit_id
  end
end
