class AddInspectionidToTags < ActiveRecord::Migration
  def change
  	add_column :tags, :inspectionid, :integer
  end
end
