class AddScreenshotsToBlog < ActiveRecord::Migration[5.2]
  def change
  	add_column :blogs, :screenshots_path, :string
  end
end
