class String
	def smash
		Flatten(JSON.parse(self)).to_json
	end
end