class ChangeHealthyTypeToText < ActiveRecord::Migration
  def change
	change_column :inspections, :healthy, :text
  end
end
