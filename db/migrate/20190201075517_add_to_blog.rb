class AddToBlog < ActiveRecord::Migration[5.2]
  def change
  	add_column :blogs ,:url ,:string
  end
end
