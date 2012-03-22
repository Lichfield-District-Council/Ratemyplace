class CreateInspections < ActiveRecord::Migration
  def change
    create_table :inspections do |t|
	  t.string :name, :null => false
	  t.text :address1, :null => false
	  t.text :address2
	  t.text :address3
	  t.text :address4
	  t.text :town, :null => false
	  t.text :postcode, :null => false
	  t.text :operator
	  t.integer :uprn
      t.string :tel
	  t.text :category, :null => false
	  t.text :scope, :null => false
      t.integer :hygiene, :null => false
      t.integer :structure, :null => false
      t.integer :confidence, :null => false
      t.integer :rating, :null => false
      t.string :image
      t.string :report
      t.boolean :tradingstandards
      t.boolean :healthy
      t.string :email
      t.string :website
      t.text :hours
      t.date :date
      t.float :lat
      t.float :lng
	  
      t.timestamps
    end
  end
end
