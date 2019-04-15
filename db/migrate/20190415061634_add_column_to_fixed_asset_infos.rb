class AddColumnToFixedAssetInfos < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_infos, :old_sys_no, :string
  end
end
