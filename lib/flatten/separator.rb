# encoding: utf-8

require 'flatten/deprecations'

module Flatten
	# Container for a separator and functionality for splitting &
	# joining with proper escaping.
	# @api private
	class Separator
		include Deprecations

		@separators = {}

		# Returns a memoized Separator object for the given separator_character
		# Evicts a member at random if memoized pool grows beyond 100.
		#
		# @param separator_character [String] (see #initialize)
		def self.[](separator_character)
			@separators[separator_character] ||= begin
				@separators.delete(@separators.keys.sample) if @separators.size > 100
				new(separator_character)
			end
		end

		# @param separator [String] single-character string
		def initialize(separator)
			unless separator.kind_of?(String) && separator.size > 0
				fail ArgumentError, "separator must be a non-empty String " +
					"got #{separator.inspect}"
			end
			deprecate('multi-character separator', '2.0') unless separator.size == 1
			@separator = separator
		end

		# Joins a pre-escaped string with a not-yet escaped string on our separator,
		# escaping the new part before joining.
		# @param pre_escaped_prefix [String]
		# @param new_part [String] - will be escaped before joining
		# @return [String]
		def join(pre_escaped_prefix, new_part)
			[pre_escaped_prefix, escape(new_part)].compact.join(@separator)
		end

		# Splits a string by our separator into non-escaped parts
		# @param str [String]
		# @return [Array<String>]
		def split(str)
			@unescaped_separator ||= /(?<!\\)(#{Regexp.escape(@separator)})/
			# String#split(<Regexp>) on non zero-width matches yields the match
			# as the even entries in the array.
			parts = str.split(@unescaped_separator).each_slice(2).map(&:first)
			parts.map do |part|
				unescape(part)
			end
		end

		private

		# backslash-escapes our separator and backlashes in a string
		# @param str [String]
		# @return [String]
		def escape(str)
			@escape_pattern ||= /(\\|#{Regexp.escape(@separator)})/
			str.gsub(@escape_pattern, '\\\\\1')
		end

		# removes backslash-escaping of our separator and backslashes from a string
		# @param str [String]
		# @return [String]
		def unescape(str)
			@unescape_pattern ||= /\\(\\|#{Regexp.escape(@separator)})/
			str.gsub(@unescape_pattern, '\1')
		end
	end
end
