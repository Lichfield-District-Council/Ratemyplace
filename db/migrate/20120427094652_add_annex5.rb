class AddAnnex5 < ActiveRecord::Migration
  def change
  	add_column :inspections, :annex5, :integer
  end
end
