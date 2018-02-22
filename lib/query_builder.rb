
module QueryBuilder
  # find pk cols for tbl
  def self.find_pk_cols(tbl)
    query = "SELECT a.attname, format_type(a.atttypid, a.atttypmod) AS data_type
	            FROM   pg_index i
	            JOIN   pg_attribute a ON a.attrelid = i.indrelid
	                                 AND a.attnum = ANY(i.indkey)
	            WHERE  i.indrelid = '#{tbl}'::regclass
	            AND    i.indisprimary;"
  end

  def self.find_uniq_key(tbl)
    query = "SELECT a.attname, format_type(a.atttypid, a.atttypmod) AS data_type
          FROM   pg_index i
          JOIN   pg_attribute a ON a.attrelid = i.indrelid
                               AND a.attnum = ANY(i.indkey)
          WHERE  i.indrelid = '#{tbl}'::regclass
          AND    i.indisunique;"

  end

  def self.get_column_data_typcategory(tbl_list,col_list)
        query = "SELECT c.relname, a.attname as colname,
 pg_catalog.format_type(a.atttypid, a.atttypmod) as data_type,typcategory
 FROM pg_catalog.pg_attribute a
 join pg_type p
 on a.atttypid = p.oid
 join pg_catalog.pg_class c
 on a.attrelid = c.oid
 where c.relname in (#{tbl_list}) AND a.attname in (#{col_list}) AND a.attnum > 0 AND NOT a.attisdropped"
    query
  end

  # test if tbl1 is subset of tbl2
  def self.subset_test(tbl1, tbl2)
    query = 'SELECT CASE WHEN (SELECT COUNT(*) FROM ( ' + tbl1 + ' ) as tbl1 )=0 '\
           ' THEN '\
           ' case when '\
           ' (SELECT COUNT(*) FROM ( ' + tbl2 + ' ) as tbl2 )>0'\
           " then 'IS NOT SUBSET'"\
           " else 'EMPTYSET'"\
           ' end '\
           ' ELSE CASE WHEN  EXISTS ( ( ' + tbl1 + ' ) except ( ' + tbl2 + ' ) )'\
           ' THEN \'IS NOT SUBSET\' ELSE \'IS SUBSET\' END '\
           ' END as result;'
  end

  # find matching columns in two tables
  def self.find_matching_cols(tbl1, tbl2)
    query = "WITH tbl1 as (select column_name, data_type FROM information_schema.columns WHERE table_name   = '#{tbl1}'),"\
            "tbl2 as (select column_name, data_type FROM information_schema.columns WHERE table_name   = '#{tbl2}')"\
            'select tbl1.column_name as col1, tbl2.column_name as col2, '\
            ' CASE  WHEN tbl1.column_name = tbl2.column_name then 1 else 0 end AS is_matching '\
            ' from tbl1 full outer join tbl2 on tbl1.column_name = tbl2.column_name;'
  end

  # find cols for tbl
  def self.group_cols_by_data_typcategory(tbl_list)
    # query = "SELECT column_name,data_type
    #         FROM information_schema.columns
    #         WHERE table_name   = '#{tbl}'"
    # puts "'#{col}'"
    query = "SELECT string_agg( c.relname||'.'||a.attname  ,',') as col_list,
 pg_catalog.format_type(a.atttypid, a.atttypmod) as data_type,typcategory,
 count(1) as count
 FROM pg_catalog.pg_attribute a
 join pg_type p
 on a.atttypid = p.oid
 join pg_catalog.pg_class c
 on a.attrelid = c.oid
 where c.relname in (#{tbl_list}) AND a.attnum > 0 AND NOT a.attisdropped
 group by data_type,typcategory"

    query
  end

  # find cols for tbl
  def self.group_cols_by_typecategory(tbl_list)
    # query = "SELECT column_name,data_type
    #         FROM information_schema.columns
    #         WHERE table_name   = '#{tbl}'"
    # puts "'#{col}'"
    query = "SELECT string_agg( c.relname||'.'||a.attname  ,',') as col_list,
 typcategory,
 count(1) as count
 FROM pg_catalog.pg_attribute a
 join pg_type p
 on a.atttypid = p.oid
 join pg_catalog.pg_class c
 on a.attrelid = c.oid
 where c.relname in (#{tbl_list}) AND a.attnum > 0 AND NOT a.attisdropped
 group by typcategory"

    query
  end


  # find cols for tbl
  def self.find_cols_by_data_typcategory(tbl, data_type = '', col = '')
    # query = "SELECT column_name,data_type
    #         FROM information_schema.columns
    #         WHERE table_name   = '#{tbl}'"
    # puts "'#{col}'"
    query = "SELECT a.attname as column_name ,c.relname,
              pg_catalog.format_type(a.atttypid, a.atttypmod) as data_type,
               p.typcategory
            FROM pg_catalog.pg_attribute a
            join pg_type p
            on a.atttypid = p.oid
            join pg_catalog.pg_class c
            on a.attrelid = c.oid
            WHERE c.relname = '#{tbl}' AND a.attnum > 0 AND NOT a.attisdropped"
    unless data_type.to_s == ''
      dataType = if data_type.is_a?(Array)
                   data_type.map { |x| "'#{x}'" }.join(',')
                 else
                   data_type
                 end
      dataTypeCond = " AND p.typcategory IN ('#{dataType}') ;"
      query += dataTypeCond
    end
    unless col.to_s == ''
      colCond = " and a.attname = '#{col}'"
      query += colCond
    end
    query
  end

  # from a list of table (tblList) find the one table that contains column colname
  def self.find_rel_by_colname(tblList, colname)
    query = "SELECT a.attname as column_name ,c.relname
      FROM pg_catalog.pg_attribute a
      join pg_catalog.pg_class c
      on a.attrelid = c.oid
      WHERE c.relname in (#{tblList}) AND a.attnum > 0 AND NOT a.attisdropped and a.attname='#{colname}'"

    query
  end

  def self.create_tbl(tblName, pkList, selectQuery)
    insertQuery = selectQuery.dup
    # pp insertQuery
    insert = insertQuery.insert(insertQuery.downcase.index(' from '), " INTO #{tblName} ")
    pkCreate = pkList.to_s.empty? ? '' : "ALTER TABLE #{tblName} ADD PRIMARY KEY (#{pkList});"
    query =  "DROP TABLE IF EXISTS #{tblName} CASCADE; #{insert}; #{pkCreate}"
  end

  # create table with unique index on not null columns
  def self.create_tbl_uix(tblName, uix, selectQuery)
    insertQuery = selectQuery.dup
    insert = insertQuery.insert(insertQuery.downcase.index(' from '), " INTO #{tblName} ")

    ix_not_null = uix.split(',').map{|pk| "#{pk} is not null"}.join(' AND ')
    create_indx = "CREATE UNIQUE INDEX idx_#{tblName} on #{tblName} (#{uix}) where #{ix_not_null}"

    query =  "DROP TABLE IF EXISTS #{tblName} CASCADE; #{insert}; #{create_indx}"
  end

  # create table with pk or unique index
  # def self.exec_create_tbl(tblName, pkList, selectQuery)
  #   create_query = self.create_tbl(tblName, pkList, selectQuery)
  #   begin
  #     # puts create_query
  #     DBConn.exec(create_query)
  #   rescue PG::NotNullViolation => e
  #     create_query = self.create_tbl_uix(tblName, pkList, selectQuery)
  #     # puts create_query
  #     DBConn.exec(create_query)
  #   end
  # end

  # def QueryBuilder.satisfactionMap(tblName,fDataset,fPKList)
  #    query = "DROP TABLE if exists #{tblName}; "
  #    pkArray = fPKList.split(',')
  #    colsQuery = QueryBuilder.find_cols_by_data_typcategory(fDataset)
  #    cols = DBConn.exec(colsQuery)
  #    cols.each do |r|
  #      unless pkArray.include? r['column_name']
  #        pkArray << " 0 as #{r['column_name']} "
  #      end
  #    end
  #    colList = pkArray.join(',')
  #    query += "select #{colList} into #{tblName} from #{fDataset};"
  #    query += "ALTER TABLE #{tblName} ADD PRIMARY KEY (#{fPKList})"
  #  end

  # def QueryBuilder.totalScore(tblName,pkList)
  #   pkArray = pkList.split(',')
  #   colsQuery = QueryBuilder.find_cols_by_data_typcategory(tblName)
  #   cols = DBConn.exec(colsQuery)
  #   colArray=[]
  #   cols.each do |r|
  #     unless pkArray.include? r['column_name']
  #       colArray << " sum(#{r['column_name']}) "
  #     end
  #   end
  #   colQuery = colArray.join('+')
  #   binding.pry
  #   query = "select ( (select #{colQuery} from #{tblName})::float/(select count(1)*#{cols.count()} from #{tblName})::float)::float as score;"
  # end

  def self.pkCondConstr(pk, tbl_alias = '')
    pk.map { |pk| (tbl_alias.empty? ? '' : "#{tbl_alias}.") + pk['col'] + ' = ' + pk['val'].to_s.str_int_rep }.join(' AND ')
    # p pkcond
  end

  def self.pkCondConstr_strip_tbl_alias(pk)
    pk.map { |f| "#{f['col'].to_s.strip_relalias} = #{f['val'].to_s.str_int_rep}" }.join(' AND ')
    # p pkcond
  end

  def self.pkCondConstr_strip_tbl_alias_colalias(pk)
    pk.map do |f|
      colname = QueryBuilder.get_colalias(f)
      "#{colname} = #{f['val'].to_s.str_int_rep}"
    end.join(' AND ')
    # p pkcond
  end

  def self.pkCondConstr_replace_tbl_alias_colalias(pk,new_tbl_alias)
    pk.map do |f|
      colname = QueryBuilder.get_colalias(f)
      "#{new_tbl_alias}.#{colname} = #{f['val'].to_s.str_int_rep}"
    end.join(' AND ')
    # p pkcond
  end

  def self.pkValConstr(pk)
    pk.map { |pk|  pk['val'].to_s.str_int_rep }.join(', ')
    # p pkcond
  end

  def self.pkValWithColConstr(pk)
    pk.map { |pk|  "#{pk['val'].to_s.str_int_rep} as #{pk['col']}" }.join(', ')
    # p pkcond
  end

  def self.pkColConstr(pk)
    pk.map { |pk|  pk['col'] }.join(', ')
    # p pkcond
  end

  # def QueryBuilder.pkColWithAliasConstr(pk)
  #   pk.map{|pk|  "#{pk['col']} as #{pk['colalias']}" }.join(', ')
  #   #p pkcond
  # end
  def self.pkJoinConstr(pk)
    pk.map { |pk|  "t.#{pk['col']} = f.#{pk['col']}" }.join(' AND ')
    # p pkcond
  end

  def self.get_colalias(col)
    col['alias'].to_s.empty? ? col['col'].to_s.strip_relalias : col['alias']
  end
end
