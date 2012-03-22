class AddInternalId < ActiveRecord::Migration
  def change
  	add_column :inspections, :internalid, :string
  end
end