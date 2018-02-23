class Column
  attr_accessor :colname, :relname, :relalias, :datatype, :typcategory, :colalias
  attr_reader :relname_fullname, :fullname, :expr, :renamed_colname, :select_name
  def fullname
    # relalias.colname
    @fullname = @relalias.to_s.empty? ? @colname : "#{@relalias}.#{@colname}"
    # @expr = @colalias.to_s.empty? ? @expr : "#{@expr} as #{@colalias}"
  end

  def relname_fullname
    # relalias.colname
    @relname_fullname = "#{@relname}.#{@colname}"
    # @expr = @colalias.to_s.empty? ? @expr : "#{@expr} as #{@colalias}"
  end

  def select_name
    @select_name = @relalias.nil? ? "#{@relname}.#{@colname}" : "#{@relalias}.#{@colname}"
  end

  def renamed_colname
    # relname_colname
    @renamed_colname = "#{@relname}_#{@colname}"
  end

  def expr
    # relalias.colname as colalias
    @expr = @colalias.to_s.empty? ? fullname : "#{fullname} as #{@colalias}"
  end

  def columnRef
    @relalias.nil? ? [@colname] : [@relalias, @colname]
  end

  def null_replacement
    case @typcategory
    when 'S'
      "'null'::#{@datatype}"
    when 'N'
      "-999::#{@datatype}"
    when 'U'
       "'00000000-0000-0000-0000-999999999999'"
    when 'D'
      "'2999-10-23'::#{@datatype}"
    end
  end

  def is_numeric_type?
    @typcategory == 'N'
  end

  def is_string_type?
    @typcategory == 'S'
  end

  def !=(other)
    if other.class == self.class
      hash != other.hash
    else
      false
    end
  end

  def ==(other)
    if other.class == self.class
      (@relname  == other.relname) && (@colname == other.colname)
    else
      false
    end
  end

  def eql?(other)
    if other.class == self.class
      (@relname == other.relname) && (@colname == other.colname)
    else
      false
    end
  end

  def hash
    [@relname, @colname].hash
  end

 # Given a Column object
   # Find the relname the column belongs to from provided from PT
  def updateRelname(fromPT)
    relNames = JsonPath.on(fromPT.to_json, '$..RANGEVAR')
    # pp relNames
    # column has no relalias or relname
    relNames.each do |rel|
      tblName = rel['relname']
      tblAlias = rel['alias'].nil? ? nil : rel['alias']['ALIAS']['aliasname']
      # pp tblName
      # pp tblAlias
      # if @relaias already exists, we only query on matching relialia
      if !@relalias.to_s.empty? && (tblName != @relalias) && (tblAlias != @relalias)
        # pp 'searching for matching @relalias'
        # binding.pry
        next
      end
      query = QueryBuilder.find_cols_by_data_typcategory(tblName, '', @colname)
      res = DBConn.exec(query)
      # pp res
      if res.count > 0
        # pp res[0]
        r = res[0]
        @relname = tblName
        @datatype = r['data_type']
        @typcategory = r['typcategory']
        if rel.key?('alias')
          @relalias = rel['alias'].nil? ? nil : rel['alias']['ALIAS']['aliasname']
        end
      end
    end
  end
end

class Synthetic_Column < Column
  attr_accessor :colname, :col_def

  def renamed_colname
    # relname_colname
    @renamed_colname = @colname
  end
end