class Page < ApplicationRecord
  belongs_to :blog
  has_many :screenshots
end
