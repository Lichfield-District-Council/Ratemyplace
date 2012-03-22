class AddAppealDateToInspections < ActiveRecord::Migration
  def change
  	add_column :inspections, :appealdate, :date
  	add_column :inspections, :appeal, :boolean
  end
end
