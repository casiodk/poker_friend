class Card < ActiveRecord::Base
	belongs_to :placement
	
	def to_s
		"#{ val }#{ suite }"
	end
end
