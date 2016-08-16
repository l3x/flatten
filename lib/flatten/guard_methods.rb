# encoding: utf-8

module Flatten
	# Methods to ensure Flatten isn't mixed into nonsensical things
	module GuardMethods
		# Flatten can be *extended* into instances of Hash
		# @param base [Hash]
		def extended(base)
			unless base.is_a? Hash
				raise ArgumentError, "<#{base.inspect}> is not a Hash!"
			end
		end

		# Sparsigy can be *included* into implementations of Hash
		# @param base [Hash.class]
		def included(base)
			unless base <= Hash
				raise ArgumentError, "<#{base.inspect} does not inherit Hash"
			end
		end
	end

	extend GuardMethods
end
