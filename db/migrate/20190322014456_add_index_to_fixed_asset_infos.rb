class AddIndexToFixedAssetInfos < ActiveRecord::Migration
  def change
  	add_index :fixed_asset_infos, :asset_no, :unique => true
  end
end
