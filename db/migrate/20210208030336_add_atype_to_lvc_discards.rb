class AddAtypeToLvcDiscards < ActiveRecord::Migration
  def change
  	add_column :lvc_discards, :atype, :string, default: 'lvc'
  end
end
