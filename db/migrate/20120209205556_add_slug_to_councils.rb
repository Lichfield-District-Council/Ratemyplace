class AddSlugToCouncils < ActiveRecord::Migration
  def change
  	add_column :councils, :slug, :string
  	add_index :councils, :slug, unique: true
  end
end
