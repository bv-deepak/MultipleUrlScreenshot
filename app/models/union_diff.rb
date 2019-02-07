class UnionDiff < ApplicationRecord
	serialize :coordinates, Array
  
	def self.create(url, coordinates)
		union_diff = UnionDiff.new(:url => url, :coordinates => coordinates, :count => 1)
		union_diff.save
	end

	def self.union_diffs(url)
		UnionDiff.where("url = ?",url)
	end
  
end