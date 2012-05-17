class AddExternalToCouncils < ActiveRecord::Migration
  def change
  	add_column :councils, :external, :boolean, :default => 1
  end
end
