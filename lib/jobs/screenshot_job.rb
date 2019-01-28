class ScreenshotJob


	def ssid
		@ssid ||= SecureRandom.hex(8)
	end

	def logger
		@logger ||= Logger.new("#{Rails.root}/log/Screenshot.log")
	end

	def perform(blog, snap_id)
		debugger
		pages = blog.pages
		pages.each do |page|
			screenshot = Screenshot.create( blog.id, page.id, snap_id, ssid)
			capture_screenshot(page.url, screenshot)
		end
	rescue => e
		logger.error("#{e}....#{e.message}")
	end

	def capture_screenshot(url, screenshot)
		uri = Addressable::URI.parse(url)
		screenshots_home_path = "#{Rails.root}/screenshots/" + uri.host
		if !File.exist?(screenshots_home_path)
			Dir.mkdir(screenshots_home_path)
		end
		response = request(url)
		if response.code == 200
			result = JSON.parse(response.body)
			screenshot_path_id = DateTime.now.to_i
			latest_screenshot_path = screenshots_home_path + "/#{screenshot_path_id}.jpg" 
			File.open(latest_screenshot_path, "wb+") {|f| f.write Base64.decode64(result["full_site_screenshot"])}
			screenshot.path_id = screenshot_path_id
			screenshot.resp_code = result["site_resp_code"]
			screenshot.state = Screenshot::State::SUCCESSFUL
		else
			screenshot.state = Screenshot::State::FAILED
		end
	rescue => e
        logger.error("Screenshot_Failed ! :#{url}, " + "#{e}, #{e.message}")
        screenshot.state = Screenshot::State::FAILED
    ensure 
		screenshot.save
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

end
