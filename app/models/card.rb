class Card
	attr_reader :suite, :val
	
	def initialize(options={})
		@suite 	= options[:suite]
		@val 		= options[:val]
	end

	def card
		"#{ val }#{ suite }"
	end
end