class AddImportColumnsToFixedAssetInfo < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_infos, :accumulate_depreciation, :float
  	add_column :fixed_asset_infos, :net_value, :float
  	add_column :fixed_asset_infos, :month_depreciation, :float
  	add_column :fixed_asset_infos, :use_status, :string
  	add_column :fixed_asset_infos, :license, :string
  end
end
