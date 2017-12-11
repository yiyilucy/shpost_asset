class ChangeChangeLogToPurchase < ActiveRecord::Migration
  def up
  	change_column :purchases, :change_log, :string, :limit => 4000
  end

  def down
  	change_column :purchases, :change_log, :string
  end
end
