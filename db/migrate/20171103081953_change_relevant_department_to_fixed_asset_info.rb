class ChangeRelevantDepartmentToFixedAssetInfo < ActiveRecord::Migration
  def change
  	change_column :fixed_asset_infos, :relevant_department, :integer
  end
end
