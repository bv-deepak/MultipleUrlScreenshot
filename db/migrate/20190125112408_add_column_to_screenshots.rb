class AddColumnToScreenshots < ActiveRecord::Migration[5.2]
  def change
    add_column :screenshots, :ssid, :string
  end
end
