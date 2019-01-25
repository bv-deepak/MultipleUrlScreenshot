class CreateScreenshots < ActiveRecord::Migration[5.2]
  def change
    create_table :screenshots do |t|
      t.references :blog, foreign_key: true
      t.references :page, foreign_key: true
      t.references :snapshot, foreign_key: true
      t.string :path_id
      t.integer :resp_code
      t.string :ssid

      t.timestamps
    end
  end
end
