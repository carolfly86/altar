class Integer
  def fact
    (1..self).reduce(:*) || 1
  end
  def bounded_fact(r)
    (self-r+1..self).reduce(:*) || 1
  end
end
