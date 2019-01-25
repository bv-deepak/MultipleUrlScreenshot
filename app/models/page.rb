class Page < ApplicationRecord
  belongs_to :blog
  has_many :screenshots
  has_many :unionchanges
  has_many :diffs
end
