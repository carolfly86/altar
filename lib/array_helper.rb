require_relative 'utils'
class Array
  # find a random value in the array that is not eqaul to the value
  def find_random_dif(value)
    newArray = self.select{|val| val != value } 
    rand = Utils.rand_in_bounds(0, newArray.length)
    newArray[rand]
  end
  # find the first hash element in array with the provided key and value
  def find_hash(k, v)
  	self.find {|x| x[k] == v}
  end
  # find the hash element in array with the provided key and value
  def find_all_hash(k, v)
    self.find_all {|x| x[k] == v}
  end

end
