class ChangeRelevantDepartmentToFixedAssetInfo < ActiveRecord::Migration
  def up
  	change_column :fixed_asset_infos, :relevant_department, :integer
  end

  def down
  	change_column :fixed_asset_infos, :relevant_department, :string
  end
end
