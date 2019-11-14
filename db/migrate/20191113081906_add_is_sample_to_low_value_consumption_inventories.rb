class AddIsSampleToLowValueConsumptionInventories < ActiveRecord::Migration
  def change
  	add_column :lvc_inventories, :is_sample, :boolean, default: false
  end
end
