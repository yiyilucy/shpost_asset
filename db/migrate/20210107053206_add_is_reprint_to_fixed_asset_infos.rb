class AddIsReprintToFixedAssetInfos < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_infos, :is_reprint, :boolean, default: false
  end
end
