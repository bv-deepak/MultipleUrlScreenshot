class ScreenshotJob

	def perform(blog, snap_id)
			pages = blog.pages
			pages.each do |page|
				Screenshot.capture_screenshot(page.url, blog.id, page.id, snap_id)
			end
	rescue => e
		put e
	end

end