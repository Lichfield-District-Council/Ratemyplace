class ChangeDefaultForAppeal < ActiveRecord::Migration
  def change
  	change_column_default :inspections, :appeal, 0
  end
end
