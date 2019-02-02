class ScreenshotJob < Struct.new(:blog, :snap_id)

	def logger
		@logger ||= Logger.new("#{Rails.root}/log/screenshot_job.log")
	end
  
	def perform
		screenshots_path = blog.get_screenshots_dir_path
		FileUtils.mkdir_p(screenshots_path) if !File.directory?(screenshots_path)
		blog.page_urls.each{ |url|
			screenshot = Screenshot.create( blog.id, url, snap_id, SecureRandom.hex)
			capture_screenshot(url, screenshot)}
	rescue => e
		logger.error("Blog_id: #{blog.id}...url: #{url}... #{e.message}....#{e.backtrace}")
	end

	def capture_screenshot(url, screenshot)
		response = Puppeteer.get_screenshot(blog, url)
		if response.code == 200
			result = JSON.parse(response.body)
			latest_screenshot_path = blog.screenshot_path(screenshot.gid)
			File.open(latest_screenshot_path, "wb+"){ |f| 
					f.write Base64.decode64(result["full_site_screenshot"])
					}
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
