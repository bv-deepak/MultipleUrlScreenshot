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
		diff_images_path = blog.get_diff_images_dir_path
		FileUtils.mkdir_p(diff_images_path) if !File.directory?(diff_images_path)
		blog.page_urls.each { |url|  create_diff_and_update_union(url) }
	rescue => e
		logger.error("Blog_id: #{blog.id}...#{e.message}..#{e.backtrace}")
	end

	def create_diff_and_update_union(url)
		src, dest = Screenshot.where("url = ? AND state = ?", url, 
				Screenshot::State::SUCCESSFUL).last(2)
		if  src && dest
			coordinates, gid, change_percent = calculate_diff(src, dest)
			Diff.create(url, src.id, dest.id, coordinates, gid, change_percent)
			update_union_coordinates(url, coordinates )
		end
	end

    def read_image(path)
		Image.read(path).first
	end

	def write_diff_image(diff_image)
		gid = SecureRandom.hex()
	    diff_image_path = blog.diff_image_path(gid)
        diff_image.write(diff_image_path)
		gid
	end

	def calculate_diff(src, dest)
		debugger
		src_path = blog.screenshot_path(src.gid)
		dest_path = blog.screenshot_path(dest.gid)
		src_image = read_image(src_path)
		dest_image = read_image(dest_path)
		coordinates = get_diff_coordinates(src_image, dest_image)
		diff_image, diff_metric = src_image.compare_channel(dest_image, Magick::AbsoluteErrorMetric)
		change_percent = calculate_percentage_diff(diff_metric, src_image.rows, dest_image.columns)
		gid = write_diff_image(diff_image)
		[coordinates, gid, change_percent]
	rescue => e
		logger.error("Diff_calculation_failed!...Blog_id: #{blog.id}...#{e.message}...#{e.backtrace}")
	end

	def calculate_percentage_diff(diff_metric, rows, columns)
		((diff_metric * 100) / (rows * columns))
	end

	def get_pixels(image)
		image.dispatch(0,0,image.columns,image.rows,"I",float=true)
	end

	def consitute_bitmap_image(src_image, dest_image)
		src_pixels = get_pixels(src_image)
		dest_pixels = get_pixels(dest_image)
		bigger_image_pixel_count = [src_pixels.count, dest_pixels.count].max
		(0...bigger_image_pixel_count).each { |i| dest_pixels[i] = (src_pixels[i] == dest_pixels[i]) ? 0.0 : 1.0 }
		rows, columns = (bigger_image_pixel_count == src_pixels.count) ? [src_image.rows, src_image.columns] :
				[dest_image.rows, dest_image.columns]
		bitmap_image = Image.constitute(columns, rows, "I", dest_pixels)
		bitmap_image_path = blog.get_screenshots_dir_path + "/bitmap_image.jpg"
		bitmap_image.write(bitmap_image_path)
		bitmap_image_path
	end

	def get_diff_coordinates(src_image, dest_image)
		bitmap_image_path = consitute_bitmap_image(src_image, dest_image)
		bitmap_image = CvMat.load(bitmap_image_path)
		kernel = IplConvKernel.new(14, 14, 7 , 7, :rect)
		bitmap_image = bitmap_image.BGR2GRAY
		bitmap_image_morpholized = bitmap_image.morphology(CV_MOP_CLOSE , kernel , 1)
		contours = bitmap_image_morpholized.find_contours(:mode => OpenCV::CV_RETR_EXTERNAL,
				:method => OpenCV::CV_CHAIN_APPROX_NONE)
		contours_array = cvpoints_to_array(contours)
	end

	def cvpoints_to_array(contours)
		array = Array.new
		while contours
			unless contours.hole?
				rect = contours.bounding_rect
				array << [rect.top_left.x, rect.top_left.y, rect.bottom_right.x, rect.bottom_right.y] 
				contours = contours.h_next
			end
		end
		array
	end

	def update_union_coordinates(url, all_coordinates)
		union_changes = Unionchange.unionchanges(url)
		all_coordinates.each { |coordinates|
			has_new_union = true
			if !union_changes.empty?
				x1, y1, x2, y2 = coordinates
				union_changes.each{ |union_change|
					ux1, uy1, ux2, uy2 = union_change.coordinates
					if intersecting?(ux1, uy1, ux2, uy2, x1, y1, x2, y2)
						has_new_union = false
						updated_union_coordinates = update_values(ux1, uy1, ux2, uy2, x1, y1, x2, y2)
						union_change.coordinates = updated_union_coordinates
						union_change.save
					end
				}
			end
			Unionchange.create(url, coordinates) if has_new_union
		}	
	end

	def intersecting?(ux1, uy1, ux2, uy2, x1, y1, x2, y2) 
		if (((ux1 <= x1 && x1 <= ux2 || ux1 <= x2 && x2 <= ux2) ||
					((x1 <= ux1 && ux1 <= x2) && (x1 <= ux2 && ux2 <= x2))) &&
					((uy1 <= y1 && y1 <= uy2 || uy1 <= y2 && y2 <= uy2) ||
					((y1 <= uy1 && uy1 <= y2) && (y1 <= uy2 && uy2 <= y2))))
			return true
		end
		return false
	end

	def update_values(ux1, uy1, ux2, uy2, x1, y1, x2, y2)
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
		[ux1, uy1, ux2, uy2]
	end

end
