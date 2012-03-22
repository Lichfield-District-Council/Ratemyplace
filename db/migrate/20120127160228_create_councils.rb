class CreateCouncils < ActiveRecord::Migration
  def change
    create_table :councils do |t|
      t.string :name
      t.string :code
      t.integer :fsaid
      t.text :address
      t.text :tel
      t.text :fax
      t.text :email
      t.text :logo

      t.timestamps
    end
  end
end
