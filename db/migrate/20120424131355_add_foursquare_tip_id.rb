class AddFoursquareTipId < ActiveRecord::Migration
  def change
  	add_column :inspections, :foursquare_tip_id, :string
  end
end
