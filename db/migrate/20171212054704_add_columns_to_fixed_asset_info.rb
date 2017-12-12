class AddColumnsToFixedAssetInfo < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_infos, :brand_model, :string
  	add_column :fixed_asset_infos, :use_years, :string
  	add_column :fixed_asset_infos, :desc1, :string
  end
end
