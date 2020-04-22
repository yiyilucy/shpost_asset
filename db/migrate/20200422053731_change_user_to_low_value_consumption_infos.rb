class ChangeUserToLowValueConsumptionInfos < ActiveRecord::Migration
  def up
    rename_column :low_value_consumption_infos, :user, :use_user
  end

  def down
    rename_column :low_value_consumption_infos, :use_user, :user
  end
end
