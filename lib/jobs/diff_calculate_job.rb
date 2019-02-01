require 'opencv'
include Magick
include OpenCV

class DiffCalculateJob < Struct.new(:blog)

	def reschedule_at(current_time, attempts)
		current_time + 1.day
	end

	def logger
		@logger ||= Logger.new("#{Rails.root}/log/diff_job.log")
	end

	def perform
		blog.page_urls.each{ |url|  perform_for_url(url) }
	rescue => e
		logger.error("Blog_id: #{blog.id}...#{e.message}..#{e.backtrace}")
	end

	def perform_for_url(url)
		screenshots = get_last_two_screenshot(url)
		if  screenshots.count == 2
			coordinates, diff_image_path, change = calculate_diff(screenshots)
			Diff.create(url, screenshots.first.id, screenshots.last.id,
					coordinates, diff_image_path, change)
			update_union_coordinates(url, coordinates )
		end
	end

	def screenshot_path(path_id)
		blog.screenshots_path + "/#{path_id}.jpg"
	end

	def get_last_two_screenshot(url)
		Screenshot.where("url = ? AND state = ? ", url, Screenshot::State::SUCCESSFUL).last(2)
	end

	def calculate_diff(screenshots)
		src_screenshot_path = screenshot_path(screenshots.first.path_id)
		dest_screenshot_path = screenshot_path(screenshots.second.path_id)
		image1 = Image.read(src_screenshot_path).first
		image2 = Image.read(dest_screenshot_path).first
		coordinates = calculate_coordinates(image1, image2)
		diff_image, diff_metric = image1.compare_channel( image2, Magick::AbsoluteErrorMetric)
		change = calculate_percentage_diff(diff_metric, image1.rows, image1.columns)
		diff_image_path = "#{blog.screenshots_path}/diffImages/" + "#{DateTime.now.to_i}.jpg"
		diff_image.write(diff_image_path)
		return coordinates, diff_image_path, change
	rescue => e
		logger.error("Diff_calculation_failed!...Blog_id: #{blog.id}...#{e.message}...#{e.backtrace}")
	end

	def calculate_percentage_diff(diff_metric, rows, columns)
		((diff_metric * 100) / (rows * columns))
	end

	def calculate_coordinates(image1, image2)
		pixelsOfimg1 = image1.dispatch(0,0,image1.columns,image1.rows,"I",float=true)
		pixelsOfimg2 = image2.dispatch(0,0,image2.columns,image2.rows,"I",float=true)
		count = [pixelsOfimg1.count ,pixelsOfimg2.count].max
		(0...count).each{ |i| pixelsOfimg2[i] = (pixelsOfimg1[i] == pixelsOfimg2[i]) ? 0.0 : 1.0}
		rows = (count == pixelsOfimg1.count) ? image1.rows : image2.rows
		columns = (count == pixelsOfimg1.count)? image1.columns : image2.columns
		bitmap_diffimage = Image.constitute(columns, rows, "I", pixelsOfimg2)
		bitmap_diffimage_path = blog.screenshots_path + "/bitmap_diffimage.jpg"
		bitmap_diffimage.write(bitmap_diffimage_path)
		bitmap_diffimage = CvMat.load(bitmap_diffimage_path)
		kernel = IplConvKernel.new(14, 14, 7 , 7, :rect)
		bitmap_diffimage = bitmap_diffimage.BGR2GRAY
		bitmap_diffimage_morpholized = bitmap_diffimage.morphology(CV_MOP_CLOSE , kernel , 1)
		contours = bitmap_diffimage_morpholized.find_contours(:mode => OpenCV::CV_RETR_EXTERNAL,
				:method => OpenCV::CV_CHAIN_APPROX_NONE)
		contours_array = cvpoints_to_Array(contours)
	end

	def cvpoints_to_Array(contours)
		array = Array.new
		while contours
			unless contours.hole?
				box = contours.bounding_rect
				coordinates = [box.top_left.x, box.top_left.y, box.bottom_right.x, box.bottom_right.y]
				array << coordinates
				contours = contours.h_next
			end
		end
		return array
	end

	def update_union_coordinates(url, all_coordinates)
		union_changes = Unionchange.unionchanges(url)
		all_coordinates.each { |coordinates|
			x1 = coordinates.first
			y1 = coordinates.second
			x2 = coordinates.third
			y2 = coordinates.fourth
			if union_changes.empty?
				Unionchange.create(url, coordinates)
			else
				flag = false
				union_changes.each{ |union_change|
					union_coordinates =	union_change.coordinates
					ux1 = union_coordinates.first
					uy1 = union_coordinates.second
					ux2 = union_coordinates.third
					uy2 = union_coordinates.fourth
					if intersecting?(ux1,uy1,ux2,uy2,x1,y1,x2,y2)
						flag = true
						updated_union_coordinates = updateValues(ux1,uy1,ux2,uy2,x1,y1,x2,y2)
						union_change.coordinates = updated_union_coordinates
						union_change.save
					end
				}
				if !flag
					new_union_coordinates = [x1, y1, x2, y2]
					Unionchange.create(url, new_union_coordinates)
				end
			end
		}
	end

	def intersecting?(ux1,uy1,ux2,uy2,x1,y1,x2,y2) 
		if (((ux1 <= x1 && x1 <= ux2 || ux1 <= x2 && x2 <= ux2) ||
					((x1 <= ux1 && ux1 <= x2) && (x1 <= ux2 && ux2 <= x2))) &&
					((uy1 <= y1 && y1 <= uy2 || uy1 <= y2 && y2 <= uy2) ||
					((y1 <= uy1 && uy1 <= y2) && (y1 <= uy2 && uy2 <= y2))))
			return true
		end
		return false
	end

	def updateValues(ux1,uy1,ux2,uy2,x1,y1,x2,y2)
		if ux1 > x1
			ux1 = x1
		end
		if ux2 < x2
			ux2 = x2
		end
		if uy1 > y1
			uy1 = y1
		end
		if uy2 < y2
			uy2 = y2
		end
		return [ux1, uy1, ux2, uy2]
	end

end
