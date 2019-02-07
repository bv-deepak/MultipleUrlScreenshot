class RenameUnionchangeModel < ActiveRecord::Migration[5.2]
  def change
  	rename_table :unionchanges, :union_diffs
  end
end
