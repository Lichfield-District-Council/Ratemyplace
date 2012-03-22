class AddPublishedToInspections < ActiveRecord::Migration
  def change
 	 add_column :inspections, :published, :boolean, :default => false
 		Inspection.all.each do |inspection|
     		inspection.update_attributes!(:published => 'false')
    	end
  end
end
