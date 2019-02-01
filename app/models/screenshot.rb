class Screenshot < ApplicationRecord
	belongs_to :blog
	belongs_to :snapshot, optional: true
  
	def self.create(blog_id, url, snap_id, ssid)
		screenshot = Screenshot.new(:blog_id => blog_id,
						:url => url,
						:snapshot_id => snap_id,
						:ssid => ssid,
						)
		screenshot.save
		return screenshot
	end

	def self.get_screenshots(url)
		Screenshot.where("url = ?", url)
	end
  
	module State
		FAILED = 0
		SUCCESSFUL = 1
	end

end
