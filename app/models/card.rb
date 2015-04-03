class Card < ActiveRecord::Base
	def to_s
		"#{ val }#{ suite }"
	end
end
