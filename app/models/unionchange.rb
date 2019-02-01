class Unionchange < ApplicationRecord
	serialize :coordinates, Array
  
	def self.create(url, coordinates)
		union_change = Unionchange.new(:url => url, :coordinates => coordinates)
		union_change.save
	end

	def self.unionchanges(url)
		Unionchange.where("url = ?",url)
	end
  
end