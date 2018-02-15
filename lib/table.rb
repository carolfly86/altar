class Table
  attr_accessor :relname, :relalias
  def initialize(name)
    @relname = name
  end

  def row_count
    # if @row_count.nil?
    query = "select count(1) as cnt from #{@relname}"
    return  DBConn.exec(query)[0]['cnt'].to_i
    # end
  end

  def intersect_query(other_tbl,target_list = '*')
    query = "select #{target_list} from #{@relname} intersect select #{target_list} from #{other_tbl.relname}"
    return query
  end

  def except_query(other_tbl,target_list = '*')
    query = "select #{target_list} from #{@relname} except select #{target_list} from #{other_tbl.relname}"
    return query
  end

  def columns()
    if @columns.nil?
      @columns = []
      query = QueryBuilder.find_cols_by_data_typcategory(@relname)
      colList = DBConn.exec(query).to_a
      colList.each do |c|
        field = Column.new
        field.colname = c['column_name']
        field.relname = @relname
        field.relalias = @relalias
        field.datatype = c['data_type']
        field.typcategory = c['typcategory']
        field.colalias = c['column_name']
        @columns << field
      end
    end
    return @columns
  end

  def pk_column_list()
    if @pk_column_list.nil?
      tbl_pk_query = QueryBuilder.find_pk_cols(@relname)
      tbl_pk_list = DBConn.exec(tbl_pk_query)
      # if cannot find pk, then use unique key instead
      if tbl_pk_list.count == 0
        tbl_pk_query = QueryBuilder.find_uniq_key(@relname)
        tbl_pk_list = DBConn.exec(tbl_pk_query)
      end
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
    # if @missing_row_count.nil?
      query = "select count(1) as cnt from #{@relname} where type = 'M'"
      return DBConn.exec(query)[0]['cnt'].to_i
    # end
     # @missing_row_count
  end

  def unwanted_row_count
    # if @unwanted_row_count.nil?
      query = "select count(1) as cnt from #{@relname} where type = 'U'"
      return  DBConn.exec(query)[0]['cnt'].to_i
    # end
    # return @unwanted_row_count
  end
end