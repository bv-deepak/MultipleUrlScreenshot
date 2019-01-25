class Screenshot < ApplicationRecord
	belongs_to :blog
	belongs_to :page
	belongs_to :snapshot, optional: true

	def self.capture_screenshot(url, blog_id, page_id, snap_id, ssid)
		debugger
		screenshot_path_id = DateTime.now.to_i
		uri = Addressable::URI.parse(url)
		screenshots_home_path = "#{Rails.root}/screenshots/" + uri.host
		if !File.exist?(screenshots_home_path)
			Dir.mkdir(screenshots_home_path)
		end
		latest_screenshot_path = screenshots_home_path + "/#{screenshot_path_id}.jpg" 
		query_params = {url: url, proxy: "", username: "", password: ""}
		begin
			result = RestClient::Request.execute({
				url: "127.0.0.1:8080/har_and_screenshot",
				user: "",
				password: "",
				method: :post,
				payload: query_params
			})
			result = JSON.parse(result.body)
			resp_code = result["site_resp_code"]
			message = "Successful"
		rescue => err
			resp_code = nil
			message = err.message()
			screenshot_path_id = nil
		end
		if resp_code
			File.open(latest_screenshot_path, "wb+") {|f| f.write Base64.decode64(result["full_site_screenshot"])}
		end
		Screenshot.create(:blog_id => blog_id,
				 :page_id => page_id,
				 :path_id => screenshot_path_id,
				 :snapshot_id => snap_id,
				 :resp_code => resp_code,
				 :ssid => ssid,
				 :message => message)
	end

end
