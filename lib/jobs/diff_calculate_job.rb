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
		FileUtils.mkdir_p(blog.get_diff_images_dir)
		blog.page_urls.each { |url|
			begin
				diff = create_diff(url)
				update_union_coordinates(url, diff.coordinates)
			rescue =>e
				logger.error("Diff_calculation_failed!...Blog_id: #{blog.id}, #{url}..."\
						"#{e.message}..#{e.backtrace}")
			end
		}
	rescue => e
		logger.error("Diff_calculation_failed!...Blog_id: #{blog.id}...#{e.message}..#{e.backtrace}")
	end

	def create_diff(url)
		has_new_screenshot = (Screenshot.where(:url => url).pluck(:state) == Screenshot::State::SUCCESSFUL) ? true : false
		src, dest = Screenshot.where("url = ? AND state = ?", url,
		            		Screenshot::State::SUCCESSFUL).last(2)
		return if (!has_new_screenshot || (!src || !dest))
		coordinates, iid, change_percent = calculate_diff(src, dest)
		Diff.create(url, src.id, dest.id, coordinates, iid, change_percent)
	end

	def read_image(path)
		Image.read(path).first
	end

	def write_diff_image(image)
		iid = SecureRandom.hex(16)
		image_path = blog.diff_image_path(iid)
		image.write(image_path)
		iid
	end

	def calculate_diff(src, dest)
		src_path = blog.screenshot_path(src.gid)
		dest_path = blog.screenshot_path(dest.gid)
		src_image = read_image(src_path)
		dest_image = read_image(dest_path)
		coordinates = get_diff_coordinates(src_image, dest_image)
		diff_image, diff_metric = src_image.compare_channel(dest_image, Magick::AbsoluteErrorMetric)
		change_percent = calculate_diff_percentage(diff_metric, diff_image)
		iid = write_diff_image(diff_image)
		[coordinates, iid, change_percent]
	end

	def calculate_diff_percentage(diff_metric, image)
		((diff_metric * 100) / (image.rows * image.columns))
	end

	def get_pixels(image)
		image.dispatch(0,0,image.columns,image.rows,"I",float=true)
	end

	def constitute_bitmap_image(src_image, dest_image)
		src_pixels = get_pixels(src_image)
		dest_pixels = get_pixels(dest_image)
		bigger_image = (src_pixels.count > dest_pixels.count) ? src_image : dest_image
		iter = [src_pixels.count, dest_pixels.count].max
		(0...iter).each { |i|
				dest_pixels[i] = (src_pixels[i] == dest_pixels[i]) ? 0.0 : 1.0
		}
		rows, columns = [bigger_image.rows, bigger_image.columns]
		bitmap_image = Image.constitute(columns, rows, "I", dest_pixels)
		bitmap_image.write("#{DateTime.now.to_i}.jpg")
		file = Tempfile.new(['bitmap_image', '.jpg'])
		bitmap_image.write(file.path)
		file
	rescue => e
		logger .error("#{e}====#{e.message}")
	end

	def get_diff_coordinates(src_image, dest_image)
		temp_file = constitute_bitmap_image(src_image, dest_image)
		response = Puppeteer.get_diff_coordinates(temp_file.path)
		if response.code == 200
			result = JSON.parse(response.body)
			return result["coordinates"]
		end
	rescue => e
		logger.error("===#{url}===#{e}-#{e.message}-#{e.backtrace}")
		raise e 
	ensure
		temp_file.unlink
	end

	def update_union_coordinates(url, all_coordinates)
		union_changes = Unionchange.unionchanges(url)
		all_coordinates.each { |coordinates|
			has_new_union = true
			if !union_changes.empty?
				x1, y1, x2, y2 = coordinates
				union_changes.each { |union_change|
					ux1, uy1, ux2, uy2 = union_change.coordinates
					if is_intersecting(ux1, uy1, ux2, uy2, x1, y1, x2, y2)
						has_new_union = false
						union_change.coordinates = update_values(ux1, uy1, ux2, uy2, x1, y1, x2, y2)
						union_change.count+=1
						union_change.save
					end
				}
			end
			Unionchange.create(url, coordinates) if has_new_union
		}	
	end

	def is_intersecting(ux1, uy1, ux2, uy2, x1, y1, x2, y2)
		if (((ux1 <= x1 && x1 <= ux2 || ux1 <= x2 && x2 <= ux2) ||
				((x1 <= ux1 && ux1 <= x2) && (x1 <= ux2 && ux2 <= x2))) &&
				((uy1 <= y1 && y1 <= uy2 || uy1 <= y2 && y2 <= uy2) ||
				((y1 <= uy1 && uy1 <= y2) && (y1 <= uy2 && uy2 <= y2))))
			return true
		end
		false
	end

	def update_values(ux1, uy1, ux2, uy2, x1, y1, x2, y2)
		ux1 = (ux1 > x1)? x1 : ux1
		ux2 = (ux2 < x2)? x2 : ux2
		uy1 = (uy1 > y1)? y1 : uy1
		uy2 = (uy2 < y2)? y2 : uy2
		[ux1, uy1, ux2, uy2]
	end

end
