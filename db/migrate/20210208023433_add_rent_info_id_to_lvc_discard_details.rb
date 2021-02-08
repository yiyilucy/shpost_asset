class AddRentInfoIdToLvcDiscardDetails < ActiveRecord::Migration
  def change
  	add_column :lvc_discard_details, :rent_info_id, :integer
  end
end
