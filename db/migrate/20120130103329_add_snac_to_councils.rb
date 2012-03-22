class AddSnacToCouncils < ActiveRecord::Migration
  def change
  	add_column :councils, :snac, :string
  end
end
