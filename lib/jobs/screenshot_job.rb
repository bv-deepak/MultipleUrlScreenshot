class ScreenshotJob

	def perform(blog, snap_id)
			pages = blog.pages
			pages.each do |page|
				ssid = SecureRandom.hex(8)
				Screenshot.capture_screenshot(page.url, blog.id, page.id, snap_id, ssid)
			end
	rescue => e
		put e
	end

end