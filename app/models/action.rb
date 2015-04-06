class Action < ActiveRecord::Base
  belongs_to :placement
  belongs_to :round
end
