class Diff < ApplicationRecord
   belongs_to :page
   belongs_to :src_screenshot, class_name: "Screenshot"
   belongs_to :dest_screenshot, class_name: "Screenshot"
   serialize :coordinates, Array 

   	def self.create(page_id, src_s_id, dest_s_id, coordinates, diff_image_path, percentage_change)
		diff = Diff.new(:page_id => page_id,
				:src_screenshot_id => src_s_id,
				:dest_screenshot_id => dest_s_id,
				:coordinates => coordinates,
				:diff_image_path => diff_image_path,
				:percentage_change => percentage_change,
			 )
		diff.save
		return Diff
	end 
end
