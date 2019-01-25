class CreateSnapshots < ActiveRecord::Migration[5.2]
  def change
    create_table :snapshots do |t|
      t.references :blog, foreign_key: true

      t.timestamps
    end
  end
end
