class ScreenshotJob < Struct.new(:blog, :snap_id)

	def ssid
		@ssid ||= SecureRandom.hex(8)
	end

	def logger
		@logger ||= Logger.new("#{Rails.root}/log/Screenshot.log")
	end

	def perform
		screenshots_path = blog.screenshots_path
		if !File.exist?(screenshots_path)
			Dir.mkdir(screenshots_path)
			Dir.mkdir(screenshots_path + "/diffImages")
		end
		blog.page_urls.each{ |url|
			screenshot = Screenshot.create( blog.id, url, snap_id, ssid)
			capture_screenshot(url, screenshot)}
	rescue => e
		logger.error("Blog_id: #{blog.id}...url: #{url}... #{e.message}....#{e.backtrace}")
	end

	def capture_screenshot(url, screenshot)
		response = Puppeteer.get_screenshot(blog, url)
		if response.code == 200
			result = JSON.parse(response.body)
			screenshot_path_id = DateTime.now.to_i
			latest_screenshot_path = blog.screenshots_path + "/#{screenshot_path_id}.jpg"
			File.open(latest_screenshot_path, "wb+"){|f| 
					f.write Base64.decode64(result["full_site_screenshot"])}
			screenshot.path_id = screenshot_path_id
			screenshot.resp_code = result["site_resp_code"]
			screenshot.state = Screenshot::State::SUCCESSFUL
		else
			screenshot.state = Screenshot::State::FAILED
		end
	rescue => e
		logger.error("Screenshot_Failed ! Blog_id: #{blog.id}...url: #{url}...#{e.message}...#{e.backtrace}")
		screenshot.state = Screenshot::State::FAILED
	ensure
		screenshot.save
	end

end
