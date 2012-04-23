class AddFoursquareVenueId < ActiveRecord::Migration
  def change
  	add_column :inspections, :foursquare_id, :string
  end
end
