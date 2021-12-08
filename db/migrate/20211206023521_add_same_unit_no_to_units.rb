class AddSameUnitNoToUnits < ActiveRecord::Migration
  def change
  	add_column :units, :same_unit_no, :string
  end
end
