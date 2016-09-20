require 'securerandom'
module Utils
	def Utils.rand_in_bounds(min, max)
	    return  (min + (max-min)*rand()).to_i
	end
	def Utils.rand_string(length = nil)
		length = 5 if length.nil?
		(0...5).map { ('a'..'z').to_a[rand(26)] }.join
	end
	def Utils.rand_bool()
		[false,true][rand(2)]
	end
	def Utils.rand_uuid()
		SecureRandom.uuid
	end
end