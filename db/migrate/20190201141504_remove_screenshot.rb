class RemoveScreenshot < ActiveRecord::Migration[5.2]
  def change
  	remove_column :blogs ,:screenshots_path
  end
end
