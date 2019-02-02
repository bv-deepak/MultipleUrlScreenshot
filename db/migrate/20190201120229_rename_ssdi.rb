class RenameSsdi < ActiveRecord::Migration[5.2]
  def change
  	rename_column :screenshots , :ssid ,:gid
  	remove_column :screenshots , :path_id
  end
end
