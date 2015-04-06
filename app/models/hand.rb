class Hand < ActiveRecord::Base
  belongs_to :table
  has_many :rounds, dependent: :destroy
  has_many :placements, dependent: :destroy
  has_many :players, through: :placements
end
