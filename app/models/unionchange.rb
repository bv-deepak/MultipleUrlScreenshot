class Unionchange < ApplicationRecord
	belongs_to :page
	serialize :coordinates, Array

	def self.create(page_id, coordinates)
		union_change = Unionchange.new(:page_id => page_id, :coordinates => coordinates)
		union_change.save
	end

end
