class ChangeOldReport < ActiveRecord::Migration
	def change
		rename_column :inspections, :report, :reportold
	end
end
