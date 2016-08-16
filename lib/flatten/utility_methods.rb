# encoding: utf-8

module Flatten
	# The Utility Methods provide a significant (~4x) performance increase
	# over extend-ing instance methods everywhere we need them.
	module UtilityMethods

		# Provides a way to iterate through a deeply-nested hash as if it were
		# a smash-hash. Used internally for generating and deconstructing smash
		# hashes.
		#
		# @overload smash_each(hsh, options = {}, &block)
		#   Yields once per key in smash version of itself.
		#   @param hsh [Hash<#to_s,Object>]
		#   @param options (see Flatten::UtilityMethods#smash)
		#   @yieldparam [(smash_key,value)]
		#   @return [void]
		# @overload smash_each(hsh, options = {})
		#   @param hsh [Hash<#to_s,Object>]
		#   @param options (see Flatten::UtilityMethods#smash)
		#   @return [Enumerator<(smash_key,value)>]
		def smash_each(hsh, options = {}, &block)
			return enum_for(:smash_each, hsh, options) unless block_given?

			inherited_prefix = options.fetch(:prefix, nil)
			separator = options.fetch(:separator, DEFAULT_SEPARATOR)
			smash_array = options.fetch(:smash_array, false)

			hsh.each do |partial_key, value|
				key = escaped_join(inherited_prefix, partial_key.to_s, separator)
				if value.kind_of?(Hash) && !value.empty?
					smash_each(value, options.merge(prefix: key), &block)
				elsif smash_array && value.kind_of?(Array) && !value.empty?
					zps = (smash_array == :zero_pad ? "%0#{value.count.to_s.size}d" : '%d') # zero-pad string
					smash_each(value.count.times.map(&zps.method(:%)).zip(value), options.merge(prefix: key), &block)
				else
					yield key, value
				end
			end
		end

		# Returns a smash version of the given hash
		#
		# @param hsh [Hash<#to_s,Object>]
		# @param options (see Flatten::UtilityMethods#smash)
		# @return [Hash<String,Object>]
		def smash(hsh, options = {})
			enum = smash_each(hsh, options)
			enum.each_with_object(Hash.new) do |(key, value), memo|
				a = key.split('.');
				flat_key = a[a.size - 1]
				if flat_key
					key = flat_key
				end
				memo[key] = value
			end
		end

		# Returns a deeply-nested version of the given smash hash
		# @param hsh [Hash<#to_s,Object>]
		# @param options (see Flatten::UtilityMethods#smash)
		# @return [Hash<String,Object>]
		def unsmash(hsh, options = {})
			separator = options.fetch(:separator, DEFAULT_SEPARATOR)
			hsh.each_with_object({}) do |(k, v), memo|
				current = memo
				key = escaped_split(k, separator)
				puts "key: #{key}"
				up_next = partial = key.shift
				until key.size.zero?
					up_next = key.shift
					up_next = up_next.to_i if (up_next =~ /\A[0-9]+\Z/)
					current = (current[partial] ||= (up_next.kind_of?(Integer) ? [] : {}))
					case up_next
						when Integer then
							raise KeyError unless current.kind_of?(Array)
						else
							raise KeyError unless current.kind_of?(Hash)
					end
					partial = up_next
				end
				current[up_next] = v
			end
		end

		# Fetch a smash key from the given deeply-nested hash.
		#
		# @overload smash_fetch(hsh, smash_key, default, options = {})
		#   @param hsh [Hash<#to_s,Object>]
		#   @param smash_key [#to_s]
		#   @param default [Object] returned if smash key not found
		#   @param options (see Flatten::UtilityMethods#smash)
		#   @return [Object]
		# @overload smash_fetch(hsh, smash_key, options = {}, &block)
		#   @param hsh [Hash<#to_s,Object>]
		#   @param smash_key [#to_s]
		#   @param options (see Flatten::UtilityMethods#smash)
		#   @yieldreturn is returned if key not found
		#   @return [Object]
		# @overload smash_fetch(hsh, smash_key, options = {})
		#   @param hsh [Hash<#to_s,Object>]
		#   @param smash_key [#to_s]
		#   @param options (see Flatten::UtilityMethods#smash)
		#   @raise KeyError if key not found
		#   @return [Object]
		def smash_fetch(hsh, smash_key, *args, &block)
			options = (args.last.kind_of?(Hash) ? args.pop : {})
			default = args.pop

			separator = options.fetch(:separator, DEFAULT_SEPARATOR)

			escaped_split(smash_key, separator).reduce(hsh) do |memo, kp|
				if memo.kind_of?(Hash) and memo.has_key?(kp)
					memo.fetch(kp)
				elsif default
					return default
				elsif block_given?
					return yield
				else
					raise KeyError, smash_key
				end
			end
		end

		# Get a smash key from the given deeply-nested hash, or return nil
		# if key not found.
		#
		# Worth noting is that Hash#default_proc is *not* used, as the intricacies
		# of implementation would lead to all sorts of terrible surprises.
		#
		# @param hsh [Hash<#to_s,Object>]
		# @param smash_key [#to_s]
		# @param options (see Flatten::UtilityMethods#smash)
		# @return [Object]
		def smash_get(hsh, smash_key, options = {})
			smash_fetch(hsh, smash_key, options) { nil }
		end

		# Given a smash hash, unflatten a subset by address, returning
		# a *modified copy* of the original smash hash.
		#
		# @overload expand(smash_hsh, smash_key, options = {}, &block)
		#   @param smash_hsh [Hash{String=>Object}]
		#   @param smash_key [String]
		#   @param options (see Flatten::UtilityMethods#smash)
		#   @return [Object]
		#
		# @example
		# ~~~ ruby
		# smash = {'a.b' => 2, 'a.c.d' => 4, 'a.c.e' => 3, 'b.f' => 4}
		# Flatten::expand(smash, 'a.c')
		# # => {'a.b' => 2, 'a.c' => {'d' => 4, 'e' => 3}, 'b.f' => 4}
		# ~~~
		def expand(smash_hsh, smash_key, *args)
			# if smash_hsh includes our key, its value is already expanded.
			return smash_hsh if smash_hsh.include?(smash_key)

			options = (args.last.kind_of?(Hash) ? args.pop : {})
			separator = options.fetch(:separator, DEFAULT_SEPARATOR)
			pattern = /\A#{Regexp.escape(smash_key)}#{Regexp.escape(separator)}/i

			match = {}
			unmatch = {}
			smash_hsh.each do |k, v|
				if pattern =~ k
					sk = k.gsub(pattern, '')
					match[sk] = v
				else
					unmatch[k] = v
				end
			end

			unmatch.update(smash_key => unsmash(match, options)) unless match.empty?
			unmatch
		end

		# Given a smash hash, unflatten a subset by address *in place*
		# (@see Flatten::UtilityMethods#expand)
		def expand!(smash_hsh, *args)
			smash_hsh.replace expand(smash_hsh, *args)
		end

		private

		# Utility method for splitting a string by a separator into
		# non-escaped parts
		# @api private
		# @param str [String]
		# @param separator [String] single-character string
		# @return [Array<String>]
		def escaped_split(str, separator)
			Separator[separator].split(str)
		end

		# Utility method for joining a pre-escaped string with a not-yet escaped
		# string on a given separator, escaping the new part before joining.
		# @api private
		# @param pre_escaped_prefix [String]
		# @param new_part [String] - will be escaped before joining
		# @param separator [String] single-character string
		# @return [String]
		def escaped_join(pre_escaped_prefix, new_part, separator)
			Separator[separator].join(pre_escaped_prefix, new_part)
		end
	end

	extend UtilityMethods
end
