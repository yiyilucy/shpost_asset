class ChangeUserToFixedAssetInfos < ActiveRecord::Migration
  def up
    rename_column :fixed_asset_infos, :user, :use_user
  end

  def down
    rename_column :fixed_asset_infos, :use_user, :user
  end
end
