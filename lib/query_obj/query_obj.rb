require 'json'
require 'pg'
require 'pg_query'
require 'jsonpath'
# require_relative 'db_connection'

class QueryObj
  attr_reader :query, :pkList,
  :table, :parseTree,
  :all_cols, :all_cols_select,
  :predicate_tree, :nullable_tbl
  attr_accessor :score

  def initialize(options)
    script = options.fetch(:queryJson, '')
    @table = options.fetch(:table)
    @score = options.fetch(:score, {})
    # initialize with script
    if script != ''
      dbname = script.split('_')[0]
      @queryJson = JSON.parse(File.read("sql/#{dbname}/#{script}.json"))
      @query = @queryJson['query']
      @pkList = @queryJson['pkList']
    # initialize with query and pklist
    else
      @query = options.fetch(:query)
      @pkList = options.fetch(:pkList)
    end
    # pp @query
    @parseTree = options.fetch(:parseTree, PgQuery.parse(@query).parsetree[0])

    @all_cols = DBConn.getAllRelFieldList(parseTree['SELECT']['fromClause'])

    create_tbl()
  end

  # from section WITHOUT where predicate
  def from_query()
    if @from_query.nil?
      if has_where_predicate?()
        @from_query = /\sfrom\s([\w\s\.\=\>\<\_\-]+)\swhere\s/i.match(query)[1]
      else
        @from_query = query[query.downcase.index(' from ')+6..query.length].gsub(';','').strip()
        # @from_query = /\sfrom\s([\w\s\.\=\>\<\_\-]+)\s(where\s)?/i.match(query)[1]
      end
    end
    return @from_query
  end

  def where_predicate()
    if @where_predicate.nil?
      if has_where_predicate?()
        @where_predicate = /\swhere\s([\w\s\.\=\>\<\_\-]+)/i.match(query)[1]
      else
        @where_predicate = ''
      end
    end
    return @where_predicate
  end

  def join_list()
    if @join_list.nil?
      @join_list = []
      if has_join?()
        @join_list =[]
        from_pt = @parseTree['SELECT']['fromClause'][0]
        rel_list = rel_list()
        join_list = JsonPath.on(from_pt, '$..JOINEXPR')
        id = join_list.count() -1
        join_list.each do |join|
          j = {}
          l_rel_list = JsonPath.on(join['larg'],'$..relname')
          r_rel_list = JsonPath.on(join['rarg'],'$..relname')
          j['jointype'] = join['jointype']
          j['l_rel_list'] = rel_list.select{|rel| l_rel_list.include?(rel.relname)}
          j['r_rel_list'] = rel_list.select{|rel| r_rel_list.include?(rel.relname)}
          j['jointype'] = join['jointype']
          j['quals'] = join['quals']
          j['id'] = id
          @join_list << j
          id = id -1
        end
      end
    end
    return @join_list
  end

  def rel_list()
    if @rel_list.nil?
      # from_pt = @parseTree['SELECT']['fromClause'][0].to_json
      @rel_list = []

      self.rel_names.each do |tbl|
        relname = tbl['relname']
        relalias = tbl['alias'].nil? ? nil : tbl['alias']['ALIAS']['aliasname']

        table = Table.new(relname)
        table.relalias = relalias

        @rel_list << table unless @rel_list.include?(table)
      end
    end
    return @rel_list
  end

  def is_plain_query()
    # create plain table from query if
    # 1. no join
    # 2. all joins are inner join
    return ((not has_join?()) or (join_types().select{|type| type.to_i != 0}.count() ==0))
  end

  def relevant_cols()
    # relevent cols include:
    # 1. all columns in where predicate, and columns of the same data type
    # 2. all columns in JOIN key, and columns of the same data type
    if @relevant_cols.nil?
      @relevant_cols = []
      # join columns
      if has_join?()
        join_list = join_list()
        rel_list = rel_list()
        join_list.each do |join|
          JsonPath.on(join['quals'],'$..fields').each do |col|
            colname = col.count > 1 ? col[1] : col[0]
            relalias = col.count > 1 ? col[0] : nil
            relname = rel_list.find{|rel| rel.relname == relalias or rel.relalias == relalias}.relname
            column = @all_cols.find{|c| c.relname == relname && c.colname == colname}
            if ((not @relevant_cols.include?(column)))
              @relevant_cols << column 
            end
          end
        end
      end
      # where predicate columns
      if has_where_predicate?()
        @predicate_tree.branches.each do |br|
          br.nodes.each do |nd|
            @relevant_cols = (@relevant_cols + nd.columns).uniq
          end
        end
      end
      # same data type columns
      if @relevant_cols.count>0
        typcategory_list = @relevant_cols.map{|c| c.typcategory}.uniq
        @all_cols.each do |col|
          if typcategory_list.include?(col.typcategory) 
            @relevant_cols << col unless @relevant_cols.include?(col)
          end
        end
      end
    end
    return @relevant_cols

  end


  def create_tbl()
    # create plain table from query if
    # 1. no join
    # 2. all joins are inner join
    is_plain_query = is_plain_query()
    if is_plain_query
      DBConn.tblCreation(@table, @pkList, @query)

      @nullable_tbl = "#{@table}_nullable"
      new_query = "select * from #{@table} where 1=2"
      DBConn.tblCreation(@nullable_tbl, '', new_query)
      puts "#{@table} is_plain_query "
    # otherwise query must contain at least one none inner join
    else
      puts "#{@table} is NOT plain_query "
      # create table without pk
      DBConn.tblCreation(@table, '', @query)
      # from_pt = @parseTree['SELECT']['fromClause'][0].to_json
      tbls = rel_list()

      pk_col_list = []

      tbls.each do |tbl|
        pkcol = tbl.pk_column_list
        if pkcol.empty?
          pk_col_list << tbl.columns
        else
          pk_col_list << pkcol
        end
      end
      # not_null_query = pk_list.flat.map{|pk| "#{pk} is not null"}.join(' AND ')
      # add index on not null columns
      pk_not_null = @pkList.split(',').map{|pk| "#{pk} is not null"}.join(' OR ')
      create_indx = "CREATE UNIQUE INDEX idx_#{@table} on #{@table} (#{@pkList}) where #{pk_not_null}"
      # pp create_indx
      DBConn.exec(create_indx)

      # pp pk_col_list
      # create a nullable table for storing nullable columns
      nullable_query = pk_col_list.map{|tbl_pks| '(' +tbl_pks.map{|pk| "#{pk.select_name} is null"}.join(" AND ") + ')'}.join(' OR ')
      all_pk_list = pk_col_list.flatten.map{|col| "#{col.select_name} as #{col.renamed_colname}"}.join(', ')
      new_query = "SELECT #{all_pk_list} FROM "+ @query.split(/ from /i)[1].rstrip
      if has_where_predicate?()
        new_query =new_query.insert( new_query.downcase.index(' where ')+7, " (#{nullable_query}) AND (")
        if new_query.end_with?(';')
          new_query = new_query.insert(new_query.length-1,")")
        else
          new_query = new_query.insert(new_query.length,")")
        end
      else
        new_query = new_query[0...new_query.length-1].rstrip if new_query.end_with?(';')
        new_query =  new_query + " WHERE #{nullable_query}"
      end
      @nullable_tbl = "#{@table}_nullable"
      # pp new_query
      DBConn.tblCreation(@nullable_tbl, '', new_query)
    end
  end

  def predicate_tree_construct(type,is_new,test_id)
    return nil unless has_where_predicate?()
    
    where_clause = @parseTree['SELECT']['whereClause']
    from_pt = @parseTree['SELECT']['fromClause']
    @predicate_tree = PredicateTree.new(type, is_new, test_id)
    root = Tree::TreeNode.new('root', '')
    @predicate_tree.build_full_pdtree(from_pt[0], where_clause, root)
  end

  def has_where_predicate?()
    where_clause = @parseTree['SELECT']['whereClause']
    return (not where_clause.nil?)
  end

  def has_join?()
    from_pt = @parseTree['SELECT']['fromClause'][0]
    return from_pt.keys.include?('JOINEXPR')
  end

  def join_types()
    if has_join?()
      from_pt = @parseTree['SELECT']['fromClause'][0].to_json
      return JsonPath.on(from_pt, '$..jointype')
    else
      return []
    end
  end

  def pk_list
    if @pk_list.nil?
      pkListQuery = QueryBuilder.find_pk_cols(@table)
      res = DBConn.exec(pkListQuery)
      # pk not exist , use unique key instead
      if res.count == 0
        pkListQuery = QueryBuilder.find_uniq_key(@table)
        res = DBConn.exec(pkListQuery)
      end
      @pk_list = []
      res.each do |r|
        @pk_list << r['attname']
      end
    end
    @pk_list
  end

  def pk_full_list
    self.pk_list
    self.rel_names
    if @pk_full_list.nil?
      @pk_full_list = []

      @pk_list.each do |pk_col|
        h = {}
        col = ReverseParseTree.find_col_by_name(@parseTree['SELECT']['targetList'], pk_col)
        h['alias'] = col['alias']
        h['col'] = col['col']
        if col['col'].split('.').count > 1
          h['colname'] = col['col'].split('.')[1]
          rel = col['col'].split('.')[0]
          @rel_names.each do |r|
            relname = JsonPath.new('$..relname').on(r)
            relalias = JsonPath.new('$..aliasname').on(r)
            if relname.include?(rel) || relalias.include?(rel)
              h['relname'] = relname[0]
              h['relalias'] = relalias.count == 0 ? rel : relalias[0]
            end
          end

        else
          h['colname'] = col['col']
          relList = @rel_names.map { |rel| "'" + rel['relname'] + "'" }.join(',')
          query = QueryBuilder.find_rel_by_colname(relList, h['colname'])
          res = DBConn.exec(query)
          h['relname'] = res[0]['relname']
          h['relalias'] = h['relname']
        end
        @pk_full_list.push(h)
      end
    end
    @pk_full_list
  end

  def rel_names
    @rel_names ||= JsonPath.on(@parseTree['SELECT']['fromClause'].to_json, '$..RANGEVAR')
  end

  # create the table containing all columns
  def create_full_rst_tbl(preserve_null_pk = true)
    unless defined? @full_rst_tbl
      self.all_cols_select
      self.pk_full_list
      if preserve_null_pk
        renamed_pk_col = @pk_full_list.map { |pk| "#{pk['col']} as #{pk['alias']}_pk" }.join(', ')
      else
        renamed_pk_col = @pk_full_list.map do |pk|
                          pkcol = @all_cols.find{|col| col.colname == pk['colname'] and col.relname==pk['relname']}
                          "COALESCE(#{pk['col']},#{pkcol.null_replacement}) as #{pk['alias']}_pk"
                        end.join(',')
      end
      targetListReplacement = "#{renamed_pk_col},#{@all_cols_select}"
      query =  ReverseParseTree.reverseAndreplace(@parseTree, targetListReplacement, '')
      @full_rst_tbl = "#{@table}_full_rst"
      pk = @pk_full_list.map { |pk| "#{pk['alias']}_pk" }.join(', ')
      # binding.pry
      DBConn.tblCreation(@full_rst_tbl, pk, query)

      # unless preserve_null_pk
      #   DBConn.update_null_columns(@full_rst_tbl,pk)
      # end
      # if is_plain_query()
      #   query = QueryBuilder.create_tbl(@full_rst_tbl, pk, query)
      #   DBConn.exec(query)
      # else
      #   query = QueryBuilder.create_tbl(@full_rst_tbl, '', query)
      #   DBConn.exec(query)

      #   # not_null_query = pk_list.flat.map{|pk| "#{pk} is not null"}.join(' AND ')
      #   # add index on not null columns
      #   pk_not_null = @pk_full_list.map { |pk| "#{pk['alias']}_pk is not null"}.join(' OR ')
      #   create_indx = "CREATE UNIQUE INDEX idx_#{@full_rst_tbl} on #{@full_rst_tbl} (#{pk}) where #{pk_not_null}"
      #   pp create_indx
      #   DBConn.exec(create_indx)

      # end
    end
    return @full_rst_tbl
  end

  # create cartesian product except satisfied table
  def create_join_excluded_tbl(preserve_null_pk = true)
    if @excluded_join_tbl.nil?
      join_list =join_list()
      cross_join_from = ''
      full_join_from = ''
      satisfied_tbl = create_satisfied_tbl()
      0.upto(join_list.count-1) do |i|
        join = join_list.find{|j| j['id'] ==i }
        l_rel_list = join['l_rel_list']
        quals = join['quals']
        q = ReverseParseTree.whereClauseConst(quals)
        has_quals = (not join['quals'].nil?)
        join_type = ReverseParseTree.joinTypeConvert(join['jointype'].to_s, has_quals)

        r_rel = join['r_rel_list'][0]
        l_arg = (i==0 ? "#{l_rel_list[0].relname} #{l_rel_list[0].relalias}" : "")
        # for efficiency only change the last join to cross join
        if i == join_list.count-1
          cross_join_from =  cross_join_from + "#{l_arg} CROSS JOIN #{r_rel.relname} #{r_rel.relalias} "
        else
          cross_join_from =  cross_join_from + "#{l_arg} #{join_type} #{r_rel.relname} #{r_rel.relalias} on #{q} "
        end
        # full_join_from =  full_join_from + "#{l_arg} CROSS JOIN #{r_rel.relname} #{r_rel.relalias} on #{q}"
      end
      @excluded_join_tbl = "#{@table}_join_excluded"
      # renamed_pk_col = @pk_full_list.map { |pk| "#{pk['col']} as #{pk['alias']}_pk" }.join(', ')
      
      if preserve_null_pk
        renamed_pk_col = @pk_full_list.map { |pk| "#{pk['col']} as #{pk['alias']}_pk" }.join(', ')
      else
        renamed_pk_col = @pk_full_list.map do |pk|
                          pkcol = @all_cols.find{|col| col.colname == pk['colname'] and col.relname==pk['relname']}
                          "COALESCE(#{pkcol.select_name},#{pkcol.null_replacement}) as #{pkcol.colalias}_pk"
                        end.join(',')
      end
      targetListReplacement = "#{renamed_pk_col},#{@all_cols_select}"
      query = ReverseParseTree.reverseAndreplace(@parseTree, targetListReplacement, '')
      old_from = from_query()
      # cross join
      all_cols_renamed()
      cross_join_query = query.gsub(/#{old_from}/i,cross_join_from)
      # pk_join_satisfied_tbl = @pk_full_list.map { |pk| "t.#{pk['alias']}_pk = s.#{pk['alias']}_pk" }.join(' AND ')
      # pk_not_in_satisfied_tbl = @pk_full_list.map { |pk| "s.#{pk['alias']}_pk is null" }.join(' OR ')

      create_tbl_query = "select * from #{satisfied_tbl} where 1=2"
      create_tbl_query = QueryBuilder.create_tbl(@excluded_join_tbl, '', create_tbl_query)
      DBConn.exec(create_tbl_query)
      # limit to 1000 rows due to resource limitation
      cross_join_query = "with cross_join as (#{cross_join_query} limit 1000) INSERT INTO #{@excluded_join_tbl} select * from (select t.* from cross_join as t except select * from #{satisfied_tbl}) as tmp"
      puts cross_join_query
      DBConn.exec(cross_join_query)

      # unless preserve_null_pk
      #   pk = @pk_full_list.map { |pk| "#{pk['alias']}_pk" }.join(',')
      #   DBConn.update_null_columns(@excluded_join_tbl,pk)
      # end
      # # full join
      # full_join_query = query.gsub(old_from,full_join_from)
      # full_join_query = "(#{full_join_query} except select #{@all_cols_renamed} from #{satisfied_tbl})"
      # full_join_query = "INSERT INTO #{@excluded_tbl} #{full_join_query}"
      # DBConn.exec(query)
    end
    return @excluded_join_tbl
  end


  # create a table containing all rows excluded by where predicate
  def create_excluded_tbl
    unless defined? @excluded_tbl
      self.all_cols_select
      self.pk_full_list
      renamed_pk_col = @pk_full_list.map { |pk| "#{pk['col']} as #{pk['alias']}_pk" }.join(', ')
      targetListReplacement = "#{renamed_pk_col},#{@all_cols_select}"
      @excluded_tbl = "#{@table}_excluded"
      excluded_predicate = get_excluded_query
      # pp excluded_predicate
      query = ReverseParseTree.reverseAndreplace(@parseTree, targetListReplacement, excluded_predicate)
      query = QueryBuilder.create_tbl(@excluded_tbl, @pk_full_list.map { |pk| "#{pk['alias']}_pk" }.join(', '), query)
      DBConn.exec(query)

      check_excluded_tup_orig
    end
    return @excluded_tbl
  end

  def check_excluded_tup_orig()
    return unless defined? @excluded_tbl
    query = "ALTER TABLE #{@excluded_tbl} ADD COLUMN failed_cols varchar(800) DEFAULT '';"
    DBConn.exec(query)
    @predicate_tree.branches.each do |br|
      br.nodes.each do |nd|
        where_pred = nd.query
        nd.columns.each do |col|
          where_pred = RewriteQuery.replace_fullname_with_renamed_colname(where_pred, col)
        end
        query = "update #{@excluded_tbl} set failed_cols = failed_cols||'#{nd.columns.map{|c| c.renamed_colname}.join(';')};'"+
        " where not (#{where_pred}) "
        # pp quer dy
        DBConn.exec(query)
      end
    end
  end

  def create_satisfied_tbl
    unless defined? @satisfied_tbl
      self.all_cols_select
      self.pk_full_list
      renamed_pk_col = @pk_full_list.map { |pk| "#{pk['col']} as #{pk['alias']}_pk" }.join(', ')
      renamed_col_list = "#{renamed_pk_col},#{@all_cols_select}"
      @satisfied_tbl = "#{@table}_satisfied"
      if (has_where_predicate? &&  !@predicate_tree.nil?)
        branch_queries = get_all_branch_queries
        pk_list =  @pk_full_list.map { |pk| "#{pk['alias']}_pk" }.join(', ') + ', branch'
        branch_queries.each_with_index do |brq,idx|
          branch = brq.keys[0]
          predicate = brq[branch]
          targetListReplacement = renamed_col_list + ",'#{branch}'::text as branch"
          query = ReverseParseTree.reverseAndreplace(@parseTree, targetListReplacement, predicate)
          if idx == 0
            query = QueryBuilder.create_tbl(@satisfied_tbl,pk_list, query)
          else
            query = "INSERT INTO #{@satisfied_tbl} #{query}"
          end
          # puts query
          DBConn.exec(query)
        end
      else
        pk_list =  @pk_full_list.map { |pk| "#{pk['alias']}_pk" }.join(', ')
        query = ReverseParseTree.reverseAndreplace(@parseTree, renamed_col_list, '')
        # query = QueryBuilder.create_tbl(@satisfied_tbl,pk_list, pk_list)
        # DBConn.exec(query)
        is_plain_query = is_plain_query()
        DBConn.create_tbl_pk_or_uq(@satisfied_tbl, pk_list, query,is_plain_query )
      end
    end
    return @satisfied_tbl
  end

  def get_excluded_query()
    if has_where_predicate?
      @predicate_tree.branches.map do |br|
        br.nodes.map { |nd| nd.query }.join(' AND ')
      end.map{|q| "NOT (#{q})"}.join(' AND ')
    else
      ''
    end
  end

  def get_branch_query(branch_name)
    branch = @predicate_tree.branches.find{|br| br.name == branch_name}
    branch.nodes.map { |nd| nd.query }.join(' AND ')
  end

  def get_all_branch_queries()
    br_queries = []
    if has_where_predicate?
      @predicate_tree.branches.each do |br|
        brq = {}
        brq[br.name] = get_branch_query(br.name)
        br_queries << brq
      end
    end
    br_queries
  end

  def all_cols_select
    @all_cols_select ||= @all_cols.map do |field|
      # col = field.relalias.nil? ? "#{field.relname}.#{field.colname}" : "#{field.relalias}.#{field.colname}"
      "#{field.select_name} as #{field.renamed_colname}"
    end.join(',')
  end

  def all_cols_renamed
    @all_cols_renamed ||= @all_cols.map do |field|
      "#{field.renamed_colname} "
    end.join(',')
  end

  # calculate stats for numeric and date columns
  def create_stats_tbl
    tblName = "#{@table}_stat"
    creationQuery = "select ''::text as key, ''::text as value from t_result where 1 =2"
    # puts creationQuery
    DBConn.tblCreation(tblName, 'key', creationQuery)

    parseTree = @parseTree

    # fromPT = parseTree['SELECT']['fromClause']
    originalTargeList = parseTree['SELECT']['targetList']
    # fields = DBConn.getAllRelFieldList(fromPT)
    keyList = []
    valueList = []
    selectList = []
    pkJoinList = []
    
    pkArray = @pkList.split(',').map { |col| col.delete(' ') }
    pkArray.each do |pkcol|
      originalTargeList.each do |targetCol|
        targetField = targetCol['RESTARGET']['val']['COLUMNREF']['fields']
        if targetField.count > 1 && targetField[1].to_s == pkcol
          pkJoinList << "t.#{pkcol} = #{targetField[0]}.#{targetField[1]}"
          pkArray.delete(pkcol)
        end
      end
    end

    stats = {
      "min": {"func": "min($COLUMN)", "type": "text" },
      "max": {"func": "max($COLUMN)", "type": "text" },
      "count": {"func": "count($COLUMN)", "type": "int" },
      "dist_count": {"func": "count(distinct $COLUMN)", "type": "int" }
    }
    @all_cols.each do |field|
      # puts field.colname
      rel_alias = field.relalias
      stats.each do |stat, info|
        # SELECT
        # UNNEST(ARRAY['address_id_max','address_id_min']) AS key,
        # UNNEST(ARRAY[max(address_id),min(address_id)]) AS value
        # FROM address
        # only add N(umeric) and D(ate) type fields
        if %w(N D).include? field.typcategory
          keyList << "'#{field.relname}_#{field.colname}_#{stat}'"
          value = info[:func].gsub('$COLUMN',"result.#{field.relname}_#{field.colname}")
          # if info[:type] == 'text'
          value = "#{value}::text"
          # end
          valueList  << value
          # valueList << "#{stat}(result.#{field.relname}_#{field.colname})::text"
        end
      end
      selectList << "#{rel_alias}.#{field.colname} as #{field.relname}_#{field.colname} "

      # construnct pk join cond
      if pkArray.include?(field.colname)
        pkJoinList << "#{@table}.#{field.colname} = #{rel_alias}.#{field.colname}"
      end
    end

    # # remove the where clause in query and replace targetList
    whereClauseReplacement = []
    selectQuery = ReverseParseTree.reverseAndreplace(parseTree, selectList.join(','), whereClauseReplacement)
    resultQuery = %(with result as (#{selectQuery} join #{@table} on #{pkJoinList.join(' AND ')}))
    newTargetList = "UNNEST(ARRAY[#{keyList.join(',')}]) AS key, UNNEST(ARRAY[#{valueList.join(',')}]) as value"

    newQuery = %(#{resultQuery} SELECT #{newTargetList} FROM result)
    query = %(INSERT INTO #{tblName} #{newQuery})
    # puts query
    DBConn.exec(query)
  end
end
