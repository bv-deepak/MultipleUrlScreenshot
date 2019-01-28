class ScreenshotJob < Struct.new(:blog, :snap_id)

	def ssid
		@ssid ||= SecureRandom.hex(8)
	end

	def logger
		@logger ||= Logger.new("#{Rails.root}/log/Screenshot.log")
	end

	def perform(blog, snap_id)
		pages = blog.pages
		pages.each do |page|
			screenshot = Screenshot.create( blog.id, page.id, snap_id, ssid)
			capture_screenshot(page, screenshot)
		end
	rescue => e
		logger.error("#{e}....#{e.message}")
	end

	def capture_screenshot(page, screenshot)
		uri = Addressable::URI.parse(page.url)
		screenshots_home_path = "#{Rails.root}/screenshots/" + uri.host
		if !File.exist?(screenshots_home_path)
			Dir.mkdir(screenshots_home_path)
		end
		response = Puppeteer.get_screenshot(page)
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
		logger.error("Screenshot_Failed ! :#{page.url}, " + "#{e}, #{e.message}")
		screenshot.state = Screenshot::State::FAILED
	ensure
		screenshot.save
	end

end