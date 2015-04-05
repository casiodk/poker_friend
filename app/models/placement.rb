class Placement < ActiveRecord::Base
  belongs_to :player
  belongs_to :hand
  has_many :cards
end
