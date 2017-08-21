require 'bigdecimal'

class String
  def is_integer?
    to_s.to_i.to_s == to_s
  end

  def str_int_rep
    # p self
    is_integer? ? self : "'" + gsub("'", "''") + "'"
  end

  def to_numeric
    if self.is_number?
      num = BigDecimal.new(self)
      if num.frac == 0
        num.to_i
      else
        num.to_f
      end
    else
      self
    end
  end

  def to_datetime
    Time.parse(self)
  end

  def str_numeric_rep(type_category)
    type_category == 'N' ? self : "'" + gsub("'", "''") + "'"
  end

  def is_number?
    true if Float(self)
  rescue
    false
  end

  def is_datetime?
    true if Time.parse(self)
  rescue
    false
  end

  def is_uuid?
    !(self =~ /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/).nil?
  end

  def is_bool?
    %w(1 0 true false).include?(self)
  end

  def typCategory
    typcategory = if is_number?
                    'N'
                  elsif is_bool?
                    'B'
                  elsif is_uuid?
                    'U'
                  else
                    'S'
                  end
    typcategory
  end

  def strip_relalias
    include?('.') ? split('.')[1].to_s : self
  end
end
