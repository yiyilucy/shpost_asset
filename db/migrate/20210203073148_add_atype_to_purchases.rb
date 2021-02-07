class AddAtypeToPurchases < ActiveRecord::Migration
  def change
  	add_column :purchases, :atype, :string, default: 'lvc'
  end
end

