class QueryObj
  
  def add_missing_branch(branches,columns)

    # if branches =~ /missing_branch/
    #   num_of_branches = branches.gsub('missing_branch','').to_i
    #   new_clause = 1.upto(num_of_branches).map do |_i|
    #     add_missing_node(columns)
    #   end.join(' OR ')

    # else
    new_clause = add_missing_node(columns)
    # end
    new_query = @query + " OR #{new_clause}"
    neighborObj = QueryObj.new(query: new_query, pkList: @pkList, table: 'neighbor')
    return neighborObj
  end
  def add_missing_node(columns)
    columns.map do |col|
                  opr = nil
                  opr = rand_operator(opr, candidateList)
                  const = optimized_rand_constant(col, opr)
                  "#{col.fullname} #{opr} #{const}" 
                end.join(' AND ')
  end

  def remove_node(location)
    predicatePath = @parseTree.get_jsonpath_from_val('location', location)
    newPS = JsonPath.for(@parseTree).delete(predicatePath) 
    newQuery = ReverseParseTree.reverse(newPS.obj)
    options = { query: newQuery, parseTree: newPS.obj, pkList: pkList, table: 'neighbor' }
    newQueryObj = QueryObj.new(options)
    pp 'new query'
    pp newQuery
    newQueryObj

  end
  # given a parse tree, generate a new predicate to replace the predicate at predicatePath
  def generate_neighbor_program(location, optimized = 1)
    whereClause = @parseTree['SELECT']['whereClause']
    predicatePath = whereClause.get_jsonpath_from_val('location', location)
    binding.pry
    predicate = JsonPath.new(predicatePath).on(whereClause).first
    fromPT = @parseTree['SELECT']['fromClause']

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

    newPredicate = predicate
    # while (tabuList.include?(element) or element.empty? )
    # if includes 1 then mutate column
    if (mutateType & 1).to_s(2) != '0'
      # type ='col'
      #   	path = '$..COLUMNREF.fields'
      # candidateList=candidateColList
      puts 'mutate column'
      oldVal = target['column']
      element['col'] = rand_column(oldVal, candidateColList)
      end
    # if includes 2 then mutate operator
    if (mutateType & 2).to_s(2) != '0'
      # type ='opr'
      #  		path = '$..AEXPR.name'
      # candidateList=OPR_SYMBOLS
      puts 'mutate operator'
      oldVal = target['opr']
      element['opr'] = rand_operator(oldVal, OPR_SYMBOLS)
      end
    # if includes 4 then mutate constant
    if (mutateType & 4).to_s(2) != '0'
      # type ='const'
      #  		path ='$..A_CONST.val'
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
    # end
    puts 'element'
    pp element
    element.keys.each do |key|
      binding.pry
      newPredicate = mutatePredicate(key, element[key], predicate)
    end
    predicatePath = "$..SELECT.whereClause.#{predicatePath.gsub('$..','')}"
    binding.pry
    newPS = JsonPath.for(@parseTree).gsub(predicatePath) { |_v| newPredicate }
    newQuery = ReverseParseTree.reverse(newPS.obj)
    options = { query: newQuery, parseTree: newPS.obj, pkList: pkList, table: 'neighbor' }
    newQueryObj = QueryObj.new(options)
    pp 'new query'
    pp newQuery
    newQueryObj
  end

  def mutatePredicate(type, newVal, predicate)
    # binding.pry
    path = case type
           when 'const'
             '$..A_CONST.val'
           when 'col'
             '$..COLUMNREF.fields'
           when 'opr'
             '$..AEXPR.name'
           end
    JsonPath.for(predicate).gsub(path) { |_v| newVal }
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
  # 	# element = Hash.new()
  # 	case type
  # 	# when 'const'
  # 	# 	randVal = rand()
  # 	# 	newVal = oldVal + randVal
  # 	# 	# element['const']=newVal
  # 	when 'col'
  # 		newVal = oldVal
  # 		while (newVal == oldVal)
  # 			newCol = candidateList[rand(candidateList.size)]
  # 			newVal = Array.new()
  # 			newVal << newCol.relalias
  # 			newVal << newCol.colname
  # 		end
  # 	when 'opr'
  # 		newVal = oldVal
  # 		while (newVal == oldVal)
  # 			newVal = candidateList[rand(candidateList.size)]
  # 		end
  # 	end
  # 	puts "newval: #{newVal}"
  # 	newVal
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
    fromPT = @parseTree['SELECT']['fromClause']
    target = {}

    target['column'] = JsonPath.on(predicate, '$..COLUMNREF.fields').to_a[0]
    target['opr'] = JsonPath.on(predicate, '$..AEXPR.name').to_a[0]
    target['const'] = JsonPath.on(predicate, '$..A_CONST.val').to_a[0]

    target
  end

  # below functions are used for optimezed random constant generating

  def optimized_rand_constant(col, opr)
    # candidateConstList = generate_candidateConstList()
    candidateConstList = get_candidateConstList(col)

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

  def get_candidateConstList(col)
    query = %(select key,value from t_result_stat
		where key in ('#{col.relname}_#{col.colname}_min','#{col.relname}_#{col.colname}_max'))
    pp query
    DBConn.exec(query)
  end
  # def get_candidateConstList(candidateColList)
  # 	candidateConstList =Hash.new()
  # 	# columns = candidateColList.clone
  # 	candidateColList.each do |col|
  # 		colVal = Hash.new()
  # 		['min','max'].each do |type|
  # 			val = get_min_max_val(col,type)
  # 			colVal.merge!( val)
  # 		end
  # 		candidateConstList[col.colname] = colVal
  # 	end
  # 	candidateConstList
  # end

  def get_min_max_val(column, type)
    # find correct pks (Union of missing pk and satisfied pk)
    # for now we get them from t_result
    rewriteCols = {}

    pkquery = "select #{@pkList} from t_result"
    # parseTree= @fQueryJson['parseTree']
    fromPT = @parseTree['SELECT']['fromClause']
    # fields = DBConn.getAllRelFieldList(fromPT)
    # remove the where clause in query
    whereClauseReplacement = []
    query_with_no_whereClause = ReverseParseTree.reverseAndreplace(@parseTree, '', whereClauseReplacement)
    # rewrite the query to return all fields
    query_with_no_whereClause, rewriteCols = RewriteQuery.return_all_fields(query_with_no_whereClause, @allCols)
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
