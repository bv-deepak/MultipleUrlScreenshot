class Screenshot < ApplicationRecord
	belongs_to :blog
	belongs_to :page
	belongs_to :snapshot, optional: true

	def self.create(blog_id, page_id, snap_id, ssid)
		screenshot = Screenshot.new(:blog_id => blog_id,
				:page_id => page_id,
				:snapshot_id => snap_id,
				:ssid => ssid,
			 )
		screenshot.save
		return screenshot
	end

	module State
		FAILED = 0
		SUCCESSFUL = 1
	end

end
