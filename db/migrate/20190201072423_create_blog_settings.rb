class CreateBlogSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :blog_settings do |t|

      t.timestamps
    end
  end
end
