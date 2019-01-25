class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.references :blog, foreign_key: true
      t.string :url

      t.timestamps
    end
  end
end
