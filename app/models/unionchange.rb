class Unionchange < ApplicationRecord
 belongs_to :page
 serialize :coordinates, Array

 def updateUnionCoordinates(page, coordinates)
		union_changes = page.unionchanges
		coordinates.each do |coordinate,value|
			x1 = coordinate.first
			y1 = coordinate.second
			x2 = coordinate.third
			y2 = coordinate.fourth
			if union_changes.empty?
				union_coordinate = [x1, y1, x2, y2]
				Unionchange.create(:page_id => page.id, :coordinates => union_coordinate)
			else
				flag = false
				union_changes.each do |union_change|
					union_coordinate =	union_change.coordinates
					ux1 = union_coordinate.first
					uy1 = union_coordinate.second
					ux2 = union_coordinate.third
					uy2 = union_coordinate.fourth
					if (((ux1 <= x1 && x1 <= ux2 || ux1 <= x2 && x2 <= ux2) ||
					     ((x1 <= ux1 && ux1 <= x2) && (x1 <= ux2 && ux2 <= x2))) &&
						 ((uy1 <= y1 && y1 <= uy2 || uy1 <= y2 && y2 <= uy2) ||
						 ((y1 <= uy1 && uy1 <= y2) && (y1 <= uy2 && uy2 <= y2))))
						flag = true
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
						updated_union_coordinate = [ux1, uy1, ux2, uy2]
						union_change.coordinates = updated_union_coordinate
						union_change.save
					end
				end
				if !flag
					new_union_coordinate = [x1, y1, x2, y2]
					Unionchange.create(:page_id => page.id, :coordinates => new_union_coordinate)
				end
			end
		end
	end
end
