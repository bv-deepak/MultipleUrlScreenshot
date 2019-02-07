class RenameIidInDiff < ActiveRecord::Migration[5.2]
  def change
  	rename_column :diffs, :iid, :image_id
  end
end
