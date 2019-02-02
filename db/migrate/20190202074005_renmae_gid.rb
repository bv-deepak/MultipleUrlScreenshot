class RenmaeGid < ActiveRecord::Migration[5.2]
  def change
  	rename_column :diffs, :gid , :iid
  end
end
