class ChangeInspectionidToInspectionId < ActiveRecord::Migration
	def change
		rename_column :tags, :inspectionid, :inspection_id
	end
end
