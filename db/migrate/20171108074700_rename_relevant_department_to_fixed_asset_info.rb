class RenameRelevantDepartmentToFixedAssetInfo < ActiveRecord::Migration
  def change
  	rename_column :fixed_asset_infos, :relevant_department, :relevant_unit_id
  end
end
