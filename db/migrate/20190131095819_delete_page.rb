class DeletePage < ActiveRecord::Migration[5.2]
  def change
  	 drop_table(:pages)
  end
end
