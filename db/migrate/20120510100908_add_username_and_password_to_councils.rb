class AddUsernameAndPasswordToCouncils < ActiveRecord::Migration
  def change
  	add_column :councils, :username, :string
  	add_column :councils, :password, :string
  end
end
