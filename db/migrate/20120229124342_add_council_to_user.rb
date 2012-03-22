class AddCouncilToUser < ActiveRecord::Migration
  def change
  	add_column :users, :councilid, :integer
  end
end
