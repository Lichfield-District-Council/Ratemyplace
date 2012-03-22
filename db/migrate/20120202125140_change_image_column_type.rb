class ChangeImageColumnType < ActiveRecord::Migration
  def up
  	change_table :inspections do |t|
  		t.has_attached_file :image
  	end
  end

  def down
  	drop_attached_file :inspections, :image
  end
end
