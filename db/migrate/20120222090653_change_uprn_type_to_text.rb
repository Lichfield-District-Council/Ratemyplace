class ChangeUprnTypeToText < ActiveRecord::Migration
  def change
	change_column :inspections, :uprn, :text
  end
end
