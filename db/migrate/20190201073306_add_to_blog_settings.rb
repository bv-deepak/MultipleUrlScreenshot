class AddToBlogSettings < ActiveRecord::Migration[5.2]
  def change
  	add_column :blog_settings ,:key ,:integer
  	add_column :blog_settings, :value ,:text
  	add_reference :blog_settings, :blog, index: true
  end
end
