class AddSlugToInspections < ActiveRecord::Migration
  def change
  	add_column :inspections, :slug, :string
  	add_index :inspections, :slug, unique: true
  end
end
