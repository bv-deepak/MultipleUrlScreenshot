class ChangeDefault < ActiveRecord::Migration[5.2]
  def change
  	change_column_default :union_diffs, :count, 1
  end
end
