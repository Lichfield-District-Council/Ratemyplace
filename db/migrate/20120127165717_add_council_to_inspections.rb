class AddCouncilToInspections < ActiveRecord::Migration
  def change
  	add_index :councils, :id
  end
end
