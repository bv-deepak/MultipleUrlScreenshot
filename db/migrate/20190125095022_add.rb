class Add < ActiveRecord::Migration[5.2]
  def change 
    add_column :diffs, :percentage_change, :float
  	add_column :diffs, :src_screenshot_id, :bigint
  	add_column :diffs, :dest_screenshot_id, :bigint 
  	add_foreign_key :diffs, :screenshots, column: :src_screenshot_id, primary_key: :id
  	add_foreign_key :diffs, :screenshots, column: :dest_screenshot_id, primary_key: :id 
  end
end
