class String
  def is_integer?
    self.to_s.to_i.to_s == self.to_s
  end

  def str_int_rep
    # p self
    self.is_integer? ? self : "'"+self.gsub("'","''")+"'"
  end

  def is_number?
  	 true if Float(self) rescue false
  end
  def is_uuid?
     !(self =~/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/).nil?
  end
  def is_bool?
     %w[1 0 true false].include?(self)
  end

  def typCategory
    if self.is_number?
      typcategory = 'N'
    elsif self.is_bool?
      typcategory = 'B'
    elsif self.is_uuid?
      typcategory = 'U'
    else
      typcategory = 'S'
    end
    typcategory
  end
  def strip_relalias
    self.include?('.') ? self.split('.')[1].to_s : self
  end
end

