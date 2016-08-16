# encoding: utf-8

module Kernel

	# @see Flatten#smash
	# @api public
	def Flatten(hsh, options = {})
		Flatten.smash(hsh, options)
	end

	private :Flatten

	# @see Flatten#unsmash
	# @api public
	def Unflatten(hsh, options = {})
		Flatten.unsmash(hsh, options)
	end

	private :Unflatten
end
