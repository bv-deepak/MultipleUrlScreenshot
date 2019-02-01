class Blog < ApplicationRecord
	has_many :snapshots
	has_many :screenshots
	has_many :settings

	def page_urls
		urls = get_setting(Blog::Setting::Key::PAGE_URLS)[urls]
		if urls
			return urls
		else
			return ["#{url}"]
		end
	end

	def get_setting(key)
		setting = settings.where(:key => key).first
		setting ? setting.value : {}
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
