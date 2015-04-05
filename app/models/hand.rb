class Hand < ActiveRecord::Base
  belongs_to :table
  has_many :rounds, dependent: :destroy
end
