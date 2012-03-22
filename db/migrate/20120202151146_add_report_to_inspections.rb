class AddReportToInspections < ActiveRecord::Migration
  def up
  	change_table :inspections do |t|
  		t.has_attached_file :report
  	end
  end

  def down
  	drop_attached_file :inspections, :report
  end
end
