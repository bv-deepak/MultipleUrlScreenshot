class CreateDiffs < ActiveRecord::Migration[5.2]
  def change
    create_table :diffs do |t|
      t.references :page, foreign_key: true
      t.text :coordinates
      t.string :diff_image_path

      t.timestamps
    end
  end
end
