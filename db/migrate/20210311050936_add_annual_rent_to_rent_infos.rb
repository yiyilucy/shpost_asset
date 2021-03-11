class AddAnnualRentToRentInfos < ActiveRecord::Migration
  def change
  	add_column :rent_infos, :annual_rent, :float
  end
end
