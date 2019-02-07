class ScreenshotDiff < ApplicationRecord
	belongs_to :src_screenshot, class_name: "Screenshot"
	belongs_to :dest_screenshot, class_name: "Screenshot"
	serialize :coordinates, Array

	def self.create(url, src_s_id, dest_s_id, coordinates, image_id, percentage_change)
		diff = ScreenshotDiff.new(
				:url => url,
				:src_screenshot_id => src_s_id,
				:dest_screenshot_id => dest_s_id,
				:coordinates => coordinates,
				:image_id => image_id,
				:percentage_change => percentage_change
		)
		diff.save
		diff
	end
end
