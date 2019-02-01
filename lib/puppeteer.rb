class Puppeteer
	def self.get_response(path, query_params, open_timeout = 20, read_timeout = 100)
		RestClient::Request.execute({
			url: "#{PUPPETEER['serverip']}/#{path}",
			user: "#{PUPPETEER['username']}",
				password: "#{PUPPETEER['password']}",
				method: :post,
				open_timeout: open_timeout,
				read_timeout: read_timeout,
				payload: query_params
		})
	end

	def self.get_screenshot(blog, url)
		random_proxy = ""
		proxy_uri = ""
		proxy = ""
		query_params = {
			url: url,
			proxy: proxy,
			username: blog.http_auth_user,
			password: blog.http_auth_password
		}
		get_response('har_and_screenshot', query_params)
	end

end
