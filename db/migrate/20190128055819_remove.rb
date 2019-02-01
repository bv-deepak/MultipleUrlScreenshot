class Remove < ActiveRecord::Migration[5.2]
  def change
  	remove_column :screenshots, :message
  end
end
