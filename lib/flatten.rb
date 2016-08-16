# encoding: utf-8

require 'flatten/version'
require 'flatten/string'
require 'flatten/hash'
require 'flatten/utility_methods'
require 'flatten/guard_methods'
require 'flatten/separator'
require 'flatten/core_ext/kernel'

# Provides smash-key access to a Hash.
#
# {'foo'=>{'bar'=>'bingo'}}.smash #=> {'foo.bar'=>'bingo'}
# {'foo.bar'=>'bingo'}.unsmash => {'foo'=>{'bar'=>'bingo'}}
#
module Flatten
	# The default separator, used if not specified in command's
	# options hash.
	DEFAULT_SEPARATOR = '.'.freeze

	# Returns a smash version of self using the options provided.
	#
	# @param options [Hash<Symbol,Object>]
	# @option options [String] :separator
	# @option options [String] :prefix
	# @option options [Boolean,:zero_pad] :smash_array (false)
	#   truthy values will cause arrays to be smashd by index and decended into.
	#   :zero_pad causes indexes to be zero-padded to make them sort lexically.
	# @return [Hash<String,Object>]
	def smash(options = {})
		Flatten.smash(self, options)
	end

	# Replaces self with smash version of itself.
	#
	# @param options (see #smash)
	# @return [Hash<String,Object>]
	def smash!(options = {})
		self.replace(smash, options)
	end

	# Used internally by both Flatten::Utility#smash and
	# Flatten::Utility#unsmash
	#
	# @overload smash_each(options = {}, &block)
	#   Yields once per key in smash version of itself.
	#   @param options (see #smash)
	#   @yieldparam [(smash_key,value)]
	#   @return [void]
	# @overload smash_each(options = {})
	#   @param options (see #smash)
	#   @return [Enumerator<(smash_key,value)>]
	def smash_each(options = {}, &block)
		Flatten.smash_each(self, options, &block)
	end

	# Follows semantics of Hash#fetch
	#
	# @overload smash_fetch(smash_key, options = {})
	#   @param options (see #smash)
	#   @raise [KeyError] if smash_key not found 
	#   @return [Object]
	# @overload smash_fetch(smash_key, default, options = {})
	#   @param options (see #smash)
	#   @param default [Object] the default object
	#   @return [default]
	# @overload smash_fetch(smash_key, options = {}, &block)
	#   @param options (see #smash)
	#   @yield if smash_key not founs
	#   @return [Object] that which was returned by the given block.
	def smash_fetch(*args, &block)
		Flatten.smash_fetch(self, *args, &block)
	end

	# Follows semantics of Hash#[] without support for Hash#default_proc
	#
	# @overload smash_get(smash_key, options = {})
	#   @param options (see #smash)
	#   @return [Object] at that address or nil if none found
	def smash_get(*args)
		Flatten.smash_get(self, *args)
	end

	# Returns a deeply-nested hash version of self.
	#
	# @param options (see #smash)
	# @return [Hash<String,Object>]
	def unsmash(options = {})
		Flatten.unsmash(self, options)
	end

	# Replaces self with deeply-nested version of self.
	#
	# @param options (see #smash)
	# @return [Hash<String,Object>]
	def unsmash!(options = {})
		self.replace(unsmash, options)
	end
end
