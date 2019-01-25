class AddColumnToScreenshots < ActiveRecord::Migration[5.2]
  def change
    add_column :screenshots, :message, :string
  end
end
