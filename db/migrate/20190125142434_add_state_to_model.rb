class AddStateToModel < ActiveRecord::Migration[5.2]
  def change
  	add_column :screenshots , :state ,:int
  end
end

def request(url)
query_params = {url: url, proxy: "", username: "", password: ""}
 response = RestClient::Request.execute({
url: "127.0.0.1:8080/har_and_screenshot",
 user: "",
 password: "",
 method: :post,
payload: query_params
      })
return response
end
