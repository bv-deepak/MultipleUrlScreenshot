class RenameInDiff < ActiveRecord::Migration[5.2]
  def change
  	rename_column :diffs, :diff_image_path, :gid
  end
end
