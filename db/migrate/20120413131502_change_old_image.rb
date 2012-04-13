class ChangeOldImage < ActiveRecord::Migration
	def change
		rename_column :inspections, :image, :imageold
	end
end