class Blog < ApplicationRecord
	has_many :snapshots
	has_many :screenshots
	has_many :settings

	def page_urls
		get_setting(Blog::Setting::Key::PAGE_URLS)["urls"] || [] << self.url 
	end

	def get_setting(key)
		setting = settings.where(:key => key).first
		setting ? setting.value : {}
	end

	def get_screenshots_dir_path
		"#{Rails.root}/screenshots"
	end

	def get_diff_images_dir_path
		"#{Rails.root}/screenshots/diff_images"
	end

	def screenshot_path(key)
		get_screenshots_dir_path + "/#{key}.jpg"
	end

	def diff_image_path(key)
		get_diff_images_dir_path + "/#{key}.jpg"
	end

	def update_setting(key, value)
		if value.to_yaml.size > 65535
			Activity.create(Activity::Type::SIZE_LIMIT_EXCEEDED, self.user_id, self.id, {:blogsetting => key})
		else
			setting = settings.where(:key => key).first
			if setting
				if value
					setting.update_attributes!(:value => value)
				else
					setting.destroy
				end
			elsif value
				Blog::Setting.create(key, value, self.id)
			end
		end
		value
	end

end
