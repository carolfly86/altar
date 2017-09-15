class Table
  attr_accessor :relname, :relalias
  def initialize(name)
    @relname = name
  end

  def row_count
    if @row_count.nil?
      query = "select count(1) as cnt from #{@relname}"
      @row_count =  DBConn.exec(query)[0]['cnt'].to_i
    end
    return @row_count
  end

  def intersect_query(other_tbl)
    query = "select * from #{@relname} intersect select * from #{other_tbl.relname}"
    return query
  end

  def pk_column_list()
    if @pk_column_list.nil?
      tbl_pk_query = QueryBuilder.find_pk_cols(@relname)
      tbl_pk_list = DBConn.exec(tbl_pk_query)
      @pk_column_list = tbl_pk_list.map do |pk|
                        column = Column.new
                        column.colname = pk['attname']
                        column.datatype = pk['data_type']
                        column.relalias = @relalias
                        column.relname = @relname
                        column
                      end
    end
    return @pk_column_list
  end

  def !=(other)
    if other.class == self.class
      @relname != other.relname
    else
      false
    end
  end

  def ==(other)
    if other.class == self.class
      @relname  == other.relname
    else
      false
    end
  end

  def eql?(other)
    if other.class == self.class
      @relname == other.relname
    else
      false
    end
  end

end

class Failing_Row_Table < Table
  attr_accessor :relname
  def initialize(name)
    @relname = name
  end

  def missing_row_count
    if @missing_row_count.nil?
      query = "select count(1) as cnt from #{@relname} where type = 'M'"
      @missing_row_count =  DBConn.exec(query)[0]['cnt'].to_i
    end
    return @missing_row_count
  end

  def unwanted_row_count
    if @unwanted_row_count.nil?
      query = "select count(1) as cnt from #{@relname} where type = 'U'"
      @unwanted_row_count =  DBConn.exec(query)[0]['cnt'].to_i
    end
    return @unwanted_row_count
  end
end