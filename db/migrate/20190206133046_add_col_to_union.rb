class AddColToUnion < ActiveRecord::Migration[5.2]
  def change
  	add_column :unionchanges, :count, :int
  end
end
