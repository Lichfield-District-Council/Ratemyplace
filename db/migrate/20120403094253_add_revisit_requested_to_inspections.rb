class AddRevisitRequestedToInspections < ActiveRecord::Migration
  def change
  	add_column :inspections, :revisit_requested, :boolean
  end
end
