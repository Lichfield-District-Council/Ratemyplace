class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|

      t.timestamps
    end
  end
end
