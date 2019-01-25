require 'opencv'
include Magick
include OpenCV
class DiffCalculateJob

	def reschedule_at(current_time, attempts)
		current_time + 1.day
	end
 
	def perform
		debugger
		blogs = Blog.all
		blogs.each do |blog|
			pages = blog.pages
			pages.each do |page|
				calculate_diff(page) 
			end
		end
	rescue => e
		put e
	ensure
		raise "Job retry"
	end

	def calculate_diff(page)
		last_two_screenshots = page.screenshots.last(2)
		uri = Addressable::URI.parse(page.url)    
		screenshots_home_path = "#{Rails.root}/screenshots/" + uri.host
		if  page.screenshots.count >= 2
			src_screenshot_path = screenshots_home_path + "/#{last_two_screenshots.last.path_id}.jpg"
			dest_screenshot_path = screenshots_home_path + "/#{last_two_screenshots.first.path_id}.jpg"
			image1 = Image.read(src_screenshot_path).first
			image2 = Image.read(dest_screenshot_path).first
			coordinates = calculate_contours(page)
			diff_image, diff_metric = image1.compare_channel( image2, Magick::AbsoluteErrorMetric)
			percentage_diff = ((diff_metric * 100) / (image1.rows * image1.columns))
			diff_image_path = "#{screenshots_home_path}/diffImages/" + "#{DateTime.now.to_i}.jpg"
			diff_image.write(diff_image_path)
			Diff.create(:page_id => page.id,
						:src_screenshot_id => last_two_screenshots.last.id,
						:dest_screenshot_id => last_two_screenshots.first.id,
						:coordinates => coordinates,
						:diff_image_path => diff_image_path,
						:percentage_diff => percentage_diff)
			Unionchange.updateUnionCoordinates(page, coordinate)
		end
	end

    def calculate_contours(image1, image2, screenshots_home_path)
		pixelsOfimg1 = image1.dispatch(0,0,image1.columns,image1.rows,"I",float=true)
		pixelsOfimg2 = image2.dispatch(0,0,image2.columns,image2.rows,"I",float=true)
		count = [pixelsOfimg1.count ,pixelsOfimg2.count].max
		for i in 0...count do
			pixelsOfimg2[i] = ( pixelsOfimg1[i] == pixelsOfimg2[i] ) ? 0.0 : 1.0
		end
		rows = (count == pixelsOfimg1.count) ? image1.rows : image2.rows
		columns = (count == pixelsOfimg1.count)? image1.columns : image2.columns
		bitmap_diffimage = Image.constitute(columns, rows, "I", pixelsOfimg2)
		bitmap_diffimage.write(screenshots_home_path + "/bitmap_diffimage.jpg")
		bitmap_diffimage = CvMat.load(screenshots_home_path + "/bitmap_diffimage.jpg")
		kernel = IplConvKernel.new(14, 14, 7 , 7, :rect)
		bitmap_diffimage = bitmap_diffimage.BGR2GRAY
		bitmap_diffimage_morpholized = bitmap_diffimage.morphology(CV_MOP_CLOSE , kernel , 1)
		contour = bitmap_diffimage_morpholized.find_contours(:mode => OpenCV::CV_RETR_EXTERNAL,
			                                                 :method => OpenCV::CV_CHAIN_APPROX_NONE)
		contours_array = Array.new
		while contour
			unless contour.hole?
				box = contour.bounding_rect
				coordinates = [box.top_left.x, box.top_left.y, box.bottom_right.x, box.bottom_right.y]
				contours_array << coordinates
				contour = contour.h_next
			end
		end
		return contour_hash
	end

end