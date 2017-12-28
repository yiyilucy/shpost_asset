class ChangeDescToUnit < ActiveRecord::Migration
  def change
  	rename_column :units, :desc, :unit_desc
  end
end
