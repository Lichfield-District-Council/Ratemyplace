class AddFoursquareNameToInspections < ActiveRecord::Migration
  def change
  	add_column :inspections, :foursquare_name, :string
  end
end
