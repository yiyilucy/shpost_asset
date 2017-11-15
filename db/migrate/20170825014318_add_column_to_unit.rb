class AddColumnToUnit < ActiveRecord::Migration
  def change
  	add_column :units, :is_facility_management_unit, :boolean, default: false
  end
end
