class AddReplyToInspections < ActiveRecord::Migration
  def change
  	add_column :inspections, :reply, :text
  end
end
