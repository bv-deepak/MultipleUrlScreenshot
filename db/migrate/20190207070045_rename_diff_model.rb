class RenameDiffModel < ActiveRecord::Migration[5.2]
  def change
  	rename_table :diffs , :screenshot_diffs
  end
end
