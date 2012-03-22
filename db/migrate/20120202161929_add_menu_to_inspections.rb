class AddMenuToInspections < ActiveRecord::Migration
  def up
  	change_table :inspections do |t|
  		t.has_attached_file :menu
  	end
  end

  def down
  	drop_attached_file :inspections, :menu
  end
end
