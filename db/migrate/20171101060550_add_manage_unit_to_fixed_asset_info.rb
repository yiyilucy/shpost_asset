class AddManageUnitToFixedAssetInfo < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_infos, :manage_unit_id, :integer
  end
end
