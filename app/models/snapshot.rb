class Snapshot < ApplicationRecord
  belongs_to :blog
  has_many :screenshots
end
