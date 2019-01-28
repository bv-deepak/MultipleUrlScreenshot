class AddHttpAuthUserToBlogs < ActiveRecord::Migration[5.2]
  def change
  	add_column :blogs, :http_auth_user, :string
  	add_column :blogs, :http_auth_password, :string
  end
end
