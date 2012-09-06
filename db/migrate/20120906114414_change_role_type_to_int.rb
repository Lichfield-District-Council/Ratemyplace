class ChangeRoleTypeToInt < ActiveRecord::Migration
  def change
	change_column :users, :role, :int
  end
end
