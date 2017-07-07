require 'securerandom'
module Utils
  def self.rand_in_bounds(min, max)
    (min + (max - min) * rand).to_i
  end

  def self.rand_string(length = nil)
    length = 5 if length.nil?
    (0...5).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def self.rand_bool
    [false, true][rand(2)]
  end

  def self.rand_uuid
    SecureRandom.uuid
  end
end
