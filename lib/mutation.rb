require 'active_support/core_ext/enumerable.rb'
class Mutation
  OPR_SYMBOLS = [['='], ['<>'], ['>'], ['<'], ['>='], ['<=']].freeze
  REMOVAL_RATIO = 0

  attr_reader :queryObj, :excluded_tbl, :satisfied_tbl, :dbname, :script
  def initialize(queryObj,excluded_tbl,satisfied_tbl,dbname,script)
    @queryObj = queryObj
    @query = queryObj.query
    @pklist = queryObj.pkList
    @parse_tree = queryObj.parseTree
    @all_cols = queryObj.all_cols
    @excluded_tbl = excluded_tbl
    @satisfied_tbl = satisfied_tbl
    @dbname = dbname
    @script = script
  end


  def generate_neighbor_query(test_rst,is_ds=false)
    @is_ds = is_ds
    # only relevant tupes are analyzed
    # 1. included tuples only satisfy branch -- include
    # 2. excluded tuples -- exclude
    # 3. if it's missing branch then included rows are missing rows
    target_cols = test_rst.columns
    if test_rst.location == "0"
      ## How to find included rows for missing branch?
      ## temporarily we assume there's only one missing branch
      ## which is not present in included_tbl by t_result
      if test_rst.branch_name =~ /missing/
        branches = @queryObj.predicate_tree.branches.map{|br| "'#{br.name}'"}.join(',')
        @included_pred = "branch not in (#{branches})"
        @included_stat = Column_Stat.new(@satisfied_tbl,@included_pred)
        if  @included_stat.get_count() == 0
          # no missing branch, try modify existing branch instead
          # find a branch that is most similar (columns) to missing columns
          target_branch = @queryObj.predicate_tree.branches.sort_by {|br| br.columns_simialrity(test_rst.columns) }.first
          @included_pred = "branch = '#{target_branch.name}'"
          @included_stat = Column_Stat.new(@satisfied_tbl,@included_pred)
          modify_branch(target_branch.name,test_rst.columns,'modify')
        else
          # if location is 0 then add missing node
          add_missing_branch(test_rst.branch_name,test_rst.columns)
        end

      else
        @included_pred = "branch = '#{test_rst.branch_name}'"
        @included_stat = Column_Stat.new(@satisfied_tbl,@included_pred)
        modify_branch(test_rst.branch_name,test_rst.columns,'add')
      end
    else
      @included_pred = "branch = '#{test_rst.branch_name}'"
      @included_stat = Column_Stat.new(@satisfied_tbl,@included_pred)
      modify_node(test_rst.branch_name,test_rst.node_name,test_rst.location, 1, test_rst.columns)
      # end
    end
  end

  def removal?(test_rst)
    dist = test_rst.get_test_row_distribution
    removal_ratio = dist['total'] == dist['M'] ? REMOVAL_RATIO : 0
    if rand() < removal_ratio
      true
    else
      false
    end
  end

  def add_missing_branch(branches,columns)
    binding.pry if columns.count == 0
    if branches =~ /missing_branch/
      num_of_branches = branches.gsub('missing_branch','').to_i
      new_clause = 1.upto(num_of_branches).map do |_i|
                      add_missing_node(columns)
                    end.join(' OR ')

    else
      new_clause = add_missing_node(columns)
    end

    if @is_ds
      neighborObj = @queryObj
    else
      new_where_clause = mutate_predicate(branches,nil,new_clause,nil)
      new_query = ReverseParseTree.reverseAndreplace(@parse_tree, '', new_where_clause)
      pp new_query
      neighborObj = QueryObj.new(query: new_query, pkList: @pkList, table: 'neighbor')
    end
    return neighborObj
  end

  # def add_node_to_branch(branch,columns)
  #   new_clauses = add_missing_node(columns)
  #   new_where_clause = @queryObj.predicate_tree.branches.map do |br|
  #                         node_query = br.nodes.map{|nd| nd.query }.join(' AND ')
  #                         if br.name == branch
  #                           node_query = node_query + ' AND '+ new_clauses
  #                         end
  #                         '( ' + node_query + ' )'
  #                       end.join(' OR ')
  #   new_query = ReverseParseTree.reverseAndreplace(@parse_tree, '', new_where_clause)
  #   neighborObj = QueryObj.new(query: new_query, pkList: @pkList, table: 'neighbor')
  #   return neighborObj
  # end

  def modify_branch(branch,columns,action)
    binding.pry if columns.count == 0
    new_clauses = add_missing_node(columns)
    new_where_clause = mutate_predicate(branch,nil,new_clauses,action)
    new_query = ReverseParseTree.reverseAndreplace(@parse_tree, '', new_where_clause)
    pp new_query

    neighborObj = @is_ds ? @queryObj : QueryObj.new(query: new_query, pkList: @pkList, table: 'neighbor')
    return neighborObj
  end

  def mutate_predicate(branch,node,new_clauses,action)
    query = @queryObj.predicate_tree.branches.map do |br|
            branch_query = br.nodes.map{|nd| nd.query }.join(' AND ')

            if br.name == branch
              # add missing node to branch
              if action == 'add'
                branch_query = branch_query + ' AND '+ new_clauses
              # modify branch
              elsif action == 'modify'
                # modify entire branch when node is nil
                if node.nil?
                  branch_query =  new_clauses
                # modify node in branch
                else
                  branch_query = br.nodes.map do |nd|
                                  nd.name == node ? new_clauses : nd.query
                                end.join(' AND ')
                end
              elsif action == 'delete'
                # delete entire branch when node is nil
                if node.nil?
                  branch_query =  ''
                # delete node in branch
                else
                  branch_query = br.nodes.select{|nd| nd.name != node }.map do |nd|
                                  nd.query 
                                 end.join(' AND ')
                end
              end
            end
            branch_query == '' ? '' : '( ' + branch_query + ' )'
          end.select{|q| q!=''}.join(' OR ')
    if branch =~ /missing_branch/
      query = query + ' OR ( '+new_clauses+')'
    end
    query
  end

  def const_element_to_s( opr,const_element, col_typcategory)
    if const_element.is_a? Array
      # in/not in
      if ['in', 'not in'].include?(opr.downcase)
        '( ' +(const_element.map{|const| const.to_s.str_numeric_rep(col_typcategory) }.join(',')) +' )'
      # between
      else
        const_element.map{|const| const.to_s.str_numeric_rep(col_typcategory) }.join(' AND ')
      end
    else
      if opr.casecmp('IS')==0 and const_element.casecmp('NULL') == 0
        'NULL'
      else
        const_element.to_s.str_numeric_rep(col_typcategory)
      end
    end
  end

  def add_missing_node(columns)

    eq_cols_clauses = find_eq_cols_clauses(columns)
    return eq_cols_clauses if columns.count == 0 

    if @is_ds
      derive_clause_from_col_ds(columns)
      return ''
    else
      remaining_clauses = columns.map do |col|
        element = derive_clause_from_col(col)
        if element == {}
          cl = ''
        else
          opr = element['opr'][0]
          cl = "#{col.fullname} #{opr} #{const_element_to_s(opr, element['const'],col.typcategory)}"
        end
        cl
        # const = optimized_rand_constant(col, opr)
      end.select{|c| c!='' }.join(' AND ')
      return eq_cols_clauses != '' && remaining_clauses != '' ? (eq_cols_clauses + ' AND ' + remaining_clauses) : (eq_cols_clauses + remaining_clauses)
    end
  end

  def find_eq_cols_clauses(columns)
    same_type_cols = columns.group_by {|c| c.datatype}.select{|k,v| v.count>1}
    eq_clauses = []
    same_type_cols.each do |datatype, cols|
      cols.combination(2).each do |cp|
        opr = @included_stat.compare_two_columns(cp[0],cp[1],['='])
        if opr == '='
          clause = "#{cp[0].select_name} = #{cp[1].select_name}"
          eq_clauses << clause
          columns.delete(cp[0])
          columns.delete(cp[1])
        end
      end
    end
    return eq_clauses.join(' AND ')
  end

  def remove_node(location)
    predicatePath = @parse_tree.get_jsonpath_from_val('location', location)

    # newPS = JsonPath.for(@parse_tree).delete(predicatePath)
    newQuery = ReverseParseTree.reverse(newPS.obj)
    options = { query: newQuery, pkList: @pkList, table: 'neighbor' }
    newQueryObj = QueryObj.new(options)
    pp 'new query'
    pp newQuery
    newQueryObj

  end

  def const_clause_from_element(element,columns,location)
    if columns.count > 1
      # if more than 1 columns defined 
      # then only operater can be mutated
      "#{columns[0].select_name} #{element['opr'][0]} #{columns[1].select_name} "
    else
      col = columns[0]
      whereClause = @parse_tree['SELECT']['whereClause']

      # pp whereClause
      # pp location
      predicatePath = whereClause.get_jsonpath_from_val('location', location)

      if predicatePath
        predicate = JsonPath.new(predicatePath).on(whereClause).first

        opr = get_val_from_element_or_predicate(element,predicate,'opr')[0]
        const = get_val_from_element_or_predicate(element,predicate,'const')
      else
        # cannot find location in predicate !
        opr = element['opr'][0]
        const = element['const']
      end
      "#{col.fullname} #{opr} #{const_element_to_s(opr, const, col.typcategory)}" 
    end
  end

  # get the value of type (opr or const) from element (if exists)
  # otherwise from existing predicate
  def get_val_from_element_or_predicate(element,predicate,type)
    if element.keys.include?(type)
      element[type]
    else
      path = case type
           when 'const'
             '$..A_CONST.val'
           when 'col'
             '$..COLUMNREF.fields'
           when 'opr'
             '$..AEXPR.name'
           end
      if type == 'const' and newVal.is_a? Array
        path = '$..AEXPR.rexpr..fields'
      end
      JsonPath.new(path).on(predicate).flatten
    end
  end

  # given a parse tree, generate a new predicate to replace the predicate at predicatePath
  def modify_node(branch,node,location, optimized = 1, columns = [])
    # fromPT = @parse_tree['SELECT']['fromClause']

    element = generate_derived_clause(columns)

    # element = generate_rand_clause(predicate,fromPT,1)
    unless element == {}
      puts 'element'
      pp element

      # predicatePath = "$..SELECT.whereClause.#{predicatePath.gsub('$..','')}"
      # newPS = JsonPath.for(@parse_tree).gsub(predicatePath) { |_v| newPredicate }.obj
      # newQuery = ReverseParseTree.reverse(newPS)
      new_clauses = const_clause_from_element(element,columns,location)
      new_where_clause = mutate_predicate(branch,node,new_clauses,'modify')

    else
      # remove node if element is {}
      new_where_clause = mutate_predicate(branch,node,'','delete')
    end
    unless @is_ds
      new_query = ReverseParseTree.reverseAndreplace(@parse_tree, '', new_where_clause)
      pp 'new query'
      pp new_query
      options = { query: new_query, pkList: @pklist, table: 'neighbor' }
      newQueryObj = QueryObj.new(options)
    else
      newQueryObj = @queryObj
    end
    newQueryObj
  end

  def mutate_predicate_by_path(type, newVal, predicate)
    # if type == 'opr' && %w(in between).include?(newVal[0].downcase)
    #   new_predicate = {}
    #   new_predicate[nil] = {}
    #   new_predicate[nil]['name'] = newVal[0] == 'in' ? ['='] : ['BETWEEN']
    #   new_predicate[nil]['lexpr'] = predicate['AEXPR']['lexpr']
    #   new_predicate[nil]['rexpr'] = predicate['AEXPR']['rexpr']
    #   new_predicate[nil]['location'] = predicate['AEXPR']['location']
    #   new_predicate
    # else
      path = case type
             when 'const'
               '$..A_CONST.val'
             when 'col'
               '$..COLUMNREF.fields'
             when 'opr'
               '$..AEXPR.name'
             end
      if type == 'const' and newVal.is_a? Array
        oldVal = JsonPath.new('$..rexpr').on(predicate).first
        # first_old_val = oldVal.is_a?(Array) ? oldVal[0] : oldVal
        binding.pry
        newVal.each do |val|
          new_val = JsonPath.for(oldVal).gsub(path) { |_v| val }.obj
          newVal.delete(val)
          newVal << new_val
        end
        path = '$..rexpr'
      end
      JsonPath.for(predicate).gsub(path) { |_v| newVal }.obj
    # end
    # predicate
  end

  # given a col in the format of ['relalias','colname'] or ['colname'] return the Column object in candidateColList
  def colRefToColObj(col, candidateColList)
    candidateColList.each do |candidate|
      if col.length > 1 # col = ['relalias','colname']
        if (candidate.colname == col[1]) && (candidate.relalias == col[0])
          return candidate
        end
      else # col = ['colname']
        return candidate if candidate.colname == col[0]
      end
    end
  end

  # def rand_candicate(type,oldVal,candidateList)
  #   # element = Hash.new()
  #   case type
  #   # when 'const'
  #   #   randVal = rand()
  #   #   newVal = oldVal + randVal
  #   #   # element['const']=newVal
  #   when 'col'
  #     newVal = oldVal
  #     while (newVal == oldVal)
  #       newCol = candidateList[rand(candidateList.size)]
  #       newVal = Array.new()
  #       newVal << newCol.relalias
  #       newVal << newCol.colname
  #     end
  #   when 'opr'
  #     newVal = oldVal
  #     while (newVal == oldVal)
  #       newVal = candidateList[rand(candidateList.size)]
  #     end
  #   end
  #   puts "newval: #{newVal}"
  #   newVal
  # end
  def rand_column(oldVal, candidateList)
    newVal = oldVal
    while newVal == oldVal
      newCol = candidateList[rand(candidateList.size)]
      newVal = []
      newVal << newCol.relalias
      newVal << newCol.colname
    end
    newVal
  end

  def rand_operator(oldVal, candidateList)
    newVal = oldVal
    newVal = candidateList[rand(candidateList.size)] while newVal == oldVal
    newVal
  end

  def rand_constant(datatypeCategory)
    case datatypeCategory
    when 'N'
      Utils.rand_in_bounds(-10.0, +10.0).to_s
    when 'S'
      Utils.rand_string
    when 'B'
      Utils.rand_bool
    when 'U'
      Utils.rand_uuid
    else
      'nil'
    end
  end

  def get_mutationTargets(predicate)
    fromPT = @parse_tree['SELECT']['fromClause']
    target = {}

    target['column'] = JsonPath.on(predicate, '$..COLUMNREF.fields').to_a[0]
    target['opr'] = JsonPath.on(predicate, '$..AEXPR.name').to_a[0]
    target['const'] = JsonPath.on(predicate, '$..A_CONST.val').to_a[0]

    target
  end

  def generate_rand_clause(predicate,fromPT,optimized)
        # all columns of the same data type
    target = get_mutationTargets(predicate)
    pp target
    candidateColList = DBConn.findRelFieldListByCol(fromPT, target['column'])

    # generate_candidateConstList(candidateColList)
    # generate_candidateConstList()
    # mutateType = rand(3)
    mutateType = rand(7) + 1
    element = {}
    puts "mutateType: #{mutateType}"

    # while (tabuList.include?(element) or element.empty? )
    # if includes 1 then mutate column
    if (mutateType & 1).to_s(2) != '0'
      # type ='col'
      #     path = '$..COLUMNREF.fields'
      # candidateList=candidateColList
      puts 'mutate column'
      oldVal = target['column']
      element['col'] = rand_column(oldVal, candidateColList)
      end
    # if includes 2 then mutate operator
    if (mutateType & 2).to_s(2) != '0'
      # type ='opr'
      #     path = '$..AEXPR.name'
      # candidateList=OPR_SYMBOLS
      puts 'mutate operator'
      oldVal = target['opr']
      element['opr'] = rand_operator(oldVal, OPR_SYMBOLS)
      end
    # if includes 4 then mutate constant
    if (mutateType & 4).to_s(2) != '0'
      # type ='const'
      #     path ='$..A_CONST.val'
      puts 'mutate constant'
      oldVal = target['const']
      col = element['col'] || target['column']
      opr = element['opr'] || target['opr']
      colname = col.size == 1 ? col[0] : col[1]
      # element['const']=rand_constant(colname, opr)
      if optimized == 0
        datatypeCategory = target['const'].to_s.typCategory
        element['const'] = rand_constant(datatypeCategory)
      else
        colObj = colRefToColObj(col, candidateColList)
        element['const'] = optimized_rand_constant(colObj, opr)
      end
    end
    return element
  end

  def generate_derived_clause(columns)
    element = {}
    if columns.count == 1
      if @is_ds
        binding.pry if columns.count == 0
        element = derive_clause_from_col_ds(columns)
      else
        element = derive_clause_from_col(columns[0])
      end
    elsif columns.count == 0
      raise "Predicate does not contain column"
    else
      operator = @included_stat.compare_two_columns(columns[0],columns[1])
      element['opr'] = [operator]
    end
    element
  end

  def derive_clause_from_col_ds(cols)
    dcm = DecisionTreeMutation.new(cols)
    dcm.python_training(@satisfied_tbl,@excluded_tbl,@dbname,@script,true,@included_pred)
    return {}
  end

  # derive the clause from given column
  def derive_clause_from_col(col)
    element = {}

    # exclude_pred = "#{col.renamed_colname} not in (select #{col.renamed_colname} from #{@satisfied_tbl})"
    # @excluded_stat = Column_Stat.new(@excluded_tbl,exclude_pred)
    @excluded_stat = Excluded_Col_Stat.new(@excluded_tbl,col)

    # abort('Unable to fix Non numeric or Datetime column') unless %(N D).include?(col.typcategory)
    ex_col_stat = @excluded_stat.get_stats(col)
    in_col_stat = @included_stat.get_stats(col)

    binding.pry if ex_col_stat['count'] == 0 or in_col_stat['count'] == 0
    puts 'ex_col_stat'
    pp ex_col_stat
    puts 'in_col_stat'
    pp in_col_stat
    if in_col_stat['is_null_count'] == in_col_stat['count'] && ex_col_stat['is_null_count'] ==0
      element['opr'] = ['IS']
      element['const'] = 'NULL'
    elsif ex_col_stat['is_null_count'] == ex_col_stat['count'] && in_col_stat['is_null_count'] ==0
      element['opr'] = ['IS NOT']
      element['const'] = 'NULL'
    elsif in_col_stat['min'] == in_col_stat['max']
      element['opr'] = ['=']
      element['const'] = in_col_stat['min']
    elsif ex_col_stat['min'] == ex_col_stat['max']
      element['opr'] = ['<>']
      element['const'] = ex_col_stat['min']
    elsif ex_col_stat['max'] < in_col_stat['min']
      if col.is_string_type?
        element = const_like_clause(in_col_stat['min'],in_col_stat['max'])
      else
        element['opr'] = ['>=']
        element['const'] = in_col_stat['min']
      end
    elsif ex_col_stat['min'] > in_col_stat['max']
      if col.is_string_type?
        element = const_like_clause(in_col_stat['min'],in_col_stat['max'])
      else
        element['opr'] = ['<=']
        element['const'] = in_col_stat['max']
      end
    elsif ex_col_stat['min'] < in_col_stat['min'] && ex_col_stat['max'] > in_col_stat['max']
      element['opr'] = ['between']
      element['const'] = [in_col_stat['min'],in_col_stat['max']]
    else
      if in_col_stat['dist_count'] <= 10 or ex_col_stat['dist_count'] <= 10
        if in_col_stat['dist_count'] <= ex_col_stat['dist_count']
          element['opr'] = ['in']
          element['const'] = @included_stat.get_distinct_vals(col)
        else
          element['opr'] = ['not in']
          element['const'] = @excluded_stat.get_distinct_vals(col)
        end
      else
        # puts 'unable to derive!'
        # binding.pry unless %(N D).include?(col.typcategory)
        if col.is_string_type?
          element = const_like_clause(in_col_stat['min'],in_col_stat['max'])
        else
          puts 'unable to derive! remove the node instead'

        end
      end
    end
    pp element
    return element
  end

  def const_like_clause(min,max)
    element = {}
    const = native_string_like([in_col_stat['min'],in_col_stat['max']])
    unless const != ''
      element['opr'] = ['LIKE']
      element['const'] = const
    end
    return element
  end

  def native_string_like(strings)
    commn_substr = longest_common_substr(strings)
    if commn_substr == ''
      return ''
    else
      if strings.map{|str| str.start_with?(commn_substr) ? 1 : 0}.sum == strings.count()
        "#{commn_substr}%"
      elsif strings.map{|str| str.start_with?(commn_substr) ? 1 : 0}.sum == strings.count()
        "%#{commn_substr}"
      else
        "%#{commn_substr}%"
      end
    end
  end

  def longest_common_substr(strings)
    shortest = strings.min_by &:length
    maxlen = shortest.length
    maxlen.downto(0) do |len|
      0.upto(maxlen - len) do |start|
        substr = shortest[start,len]
        return substr if strings.all?{|str| str.include? substr }
      end
    end
  end


  # below functions are used for optimezed random constant generating

  def optimized_rand_constant(col, opr)
    # candidateConstList = generate_candidateConstList()
    candidateConstList = get_candidateConstList(col, 't_result_stat')

    min = ''
    max = ''
    candidateConstList.each do |candidate|
      pp candidate
      if candidate['key'] == "#{col.relname}_#{col.colname}_min"
        min = candidate['value']
      elsif candidate['key'] == "#{col.relname}_#{col.colname}_max"
        max = candidate['value']
      end
    end
    pp candidateConstList
    pp col
    pp opr
    puts "min: #{min}"
    puts "max: #{max}"

    case opr[0].to_s
    when '>', '>='
      newVal = min
    when '<', '<='
      newVal = max
    # when '='
    else
      randVal = rand(2)
      newVal = randVal == 1 ? max : min
    end
    pp "newval: #{newVal}"
    newVal
  end

  def get_candidateConstList(col,stat_tbl)
    query = %(select key,value from #{stat_tbl}
    where key in ('#{col.relname}_#{col.colname}_min',
    '#{col.relname}_#{col.colname}_max',
    '#{col.relname}_#{col.colname}_count'))
    pp query
    DBConn.exec(query)
  end
  # def get_candidateConstList(candidateColList)
  #   candidateConstList =Hash.new()
  #   # columns = candidateColList.clone
  #   candidateColList.each do |col|
  #     colVal = Hash.new()
  #     ['min','max'].each do |type|
  #       val = get_min_max_val(col,type)
  #       colVal.merge!( val)
  #     end
  #     candidateConstList[col.colname] = colVal
  #   end
  #   candidateConstList
  # end

  def get_min_max_val(column, type)
    # find correct pks (Union of missing pk and satisfied pk)
    # for now we get them from t_result
    rewriteCols = {}

    pkquery = "select #{@pkList} from t_result"
    # parseTree= @fQueryJson['parseTree']
    fromPT = @parse_tree['SELECT']['fromClause']
    # fields = DBConn.getAllRelFieldList(fromPT)
    # remove the where clause in query
    whereClauseReplacement = []
    query_with_no_whereClause = ReverseParseTree.reverseAndreplace(@parse_tree, '', whereClauseReplacement)
    # rewrite the query to return all fields
    query_with_no_whereClause, rewriteCols = RewriteQuery.return_all_fields(query_with_no_whereClause, @all_cols)
    pkjoin = @pkList.split(',').map do |pkcol|
      t_pkcol = if rewriteCols.key?(pkcol)
                  "t.#{pkcol}"
                else
                  "t.#{pkcol}"
                end
      "pk.#{pkcol} = #{t_pkcol}"
    end.join(' AND ')
    col = if rewriteCols.key?(column.colname)
            "t.#{column.relname}_#{column.colname}"
          else
            "t.#{column.colname}"
      end
    # fromPT = @fQueryJson['parseTree']['SELECT']['fromClause']
    query = "with pk as (#{pkquery}), t as (#{query_with_no_whereClause})
        select #{type}(#{col})  from t join pk on #{pkjoin}"

    pp query
    rst = DBConn.exec(query)
    rst[0]
  end
end