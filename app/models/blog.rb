class Blog < ApplicationRecord
	has_many :snapshots
	has_many :screenshots
	
	def urls
		return [ "https://blogvault.net/" , "https://blogvault.net/features/"]
	end 
end
