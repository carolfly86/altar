require 'jsonpath'
require 'distribution'
# require_relative 'reverse_parsetree'
# require_relative 'db_connection'
# require_relative 'random_gaussian'
# require_relative 'localizeError'
class HillClimbingAlg
	def initialize(fqueryObj,tqueryObj)
		@max_iter = 100
		# probablity of adding noise
		# @p = 0.8
	 #    @bouts = 5
	    @numericOperators = [['+'], ['-'], ['*'], ['/']]
	    # @keywords = [ 'AND', 'NOT', 'OR', '']
	    # @oprSymbols= { 
	    # 	"~~" => [ ['='],['<>'], ['>'], ['<'],],
	    # 	"=" => [ ['<>'], ['>'], ['<'],],
	    # 	"<>" => [ ['='], ['>'], ['<'],],
	    # 	">"=> [ ['<'], ['<>'], ['='],],
	    # 	"<"=> [ ['>'], ['<>'], ['='],]
	    # }
	    @oprSymbols = [ ['='],['<>'], ['>'], ['<'], ['>='], ['<=']]
	    @fqueryObj=fqueryObj
	    @tqueryObj=tqueryObj
	    @pk= @fqueryObj.pkList

	end
	def random_binary_str(length)
		str = ''
		while (length>0)
			str = str+rand(2).to_s
			length = length -1
		end
		return str
	end

	# Given a false query, location of suspicious predicate, along with additional information needed to validate the result
	# mutate the suspicious predicate, try to find a query that produces better score
	def hill_climbing(location)
		best = @fqueryObj
		score = @fqueryObj.score
		loc =  location.to_s
		parseTree= @fqueryObj.parseTree

		# create stat table
		@tqueryObj.create_stats_tbl
		# rst = parseTree.constr_jsonpath_to_location(location)
		# last=rst.count-1
		# rst.delete_at(last)

		# predicatePath = '$..'+rst.map{|x| "'#{x}'"}.join('.')
		# predicatePath = parseTree.get_jsonpath_from_location(location)
		# predicate = JsonPath.new(predicatePath).on(parseTree)

		# generate_candiateList(predicate)
		# generate_candidateConstList()
		# @tabuList=[]

		i = 0
		while ( i<=@max_iter and score[loc].to_i >0 )
			# neighbor = generate_neighbor_program(parseTree,predicatePath)
			neighbor = @fqueryObj.generate_neighbor_program(location,1)
			if neighbor.nil?
				puts 'no candidates available! '
				break
			end
			# neighbor.table='evl_tbl'
			evaluate_query(neighbor,@tqueryObj)
			s=neighbor.score
			
			if s[loc].to_i < score[loc].to_i
				score = s
				best = neighbor
			end
			puts "iteration: #{i}"
			puts'current best query'
			puts best.query
			i+=1
		end
	end


	# private

	def evaluate_query(evlQueryObj,tqueryObj)
		# DBConn.tblCreation(evlQueryJson['table'],evlQueryJson['pkList'], evlQueryJson['query'])
		localizeErr = LozalizeError.new(evlQueryObj,tqueryObj,false)
	    localizeErr.selecionErr()
	    score = localizeErr.getSuspiciouScore()
	    puts 'neighbor score'
	    pp score
	    evlQueryObj.score=score
	end

	# given a parse tree, generate a new predicate to replace the predicate at predicatePath
	# def generate_neighbor_program(parseTree,predicatePath)
	# 	# mutateType = rand(3)
	# 	mutateType = rand(7)+1
	# 	element = Hash.new()
	# 	puts "mutateType: #{mutateType}"
	# 	predicate = JsonPath.new(predicatePath).on(parseTree)
	# 	# newPredicate= predicate
	# 	while (@tabuList.include?(element) or element.empty? )
	# 		# if includes 1 then mutate column
	# 		if ( mutateType & 1 ).to_s(2) != "0"
	# 			type ='col'
	# 		   	path = '$..COLUMNREF.fields'
	# 		   	candidateList=@candidateColList
	# 		   	oldVal = @column
	# 		   	element['col']=rand_candicate(type,oldVal,candidateList)
	# 		end
	# 		# if includes 2 then mutate operator
	# 		if ( mutateType & 2 ).to_s(2) != "0"
	# 			type ='opr'
	# 	   		path = '$..AEXPR.name'
	# 	   		candidateList=@candidateOprList
	# 	   		oldVal = @opr
	# 			element['opr']=rand_candicate(type,oldVal,candidateList)
	# 		end
	# 		# if includes 4 then mutate constant
	# 		if ( mutateType & 4 ).to_s(2) != "0"
	# 			type ='const'
	# 	   		path ='$..A_CONST.val'
	# 	   		oldVal =@const
	# 	   		col = element['col'] || @column
	# 	   		opr = element['opr'] || @opr
	# 	   		colname = col.size == 1 ? col[0] : col[1]
	# 	   		element['const']=rand_constant(colname, opr)
	# 		end
	# 	end
	# 	puts "element"
	# 	pp element
	# 	element.keys.each do |key|
	# 		pp key
	# 		newPredicate = mutatePredicate(key,element[key],predicate)
	# 	end
	# 	newPS=JsonPath.for(parseTree).gsub(predicatePath){|v| newPredicate}
	# 	newQuery = ReverseParseTree.reverse(newPS.obj)
	# 	newQueryJson = @fqueryObj.clone

	# 	newQueryJson['query'] = newQuery
	# 	newQueryJson['parseTree'] = newPS.obj
	# 	newQueryJson['score']=Hash.new()
	# 	pp "new query"
	# 	pp newQuery
	# 	return newQueryObj
	# end
	# def mutatePredicate(type,newVal,predicate)
 # 		path = case type
	# 	 		when 'const'
	# 	 			'$..A_CONST.val'
	# 	 		when 'col'
	# 	 		    '$..COLUMNREF.fields'
	# 	 		when 'opr'
	# 	 			'$..AEXPR.name'
	# 	 		end
	# 	JsonPath.for(predicate).gsub!(path){|v| newVal}
	# 	return predicate[0]	
	# end

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
	# def rand_constant(col, opr)
	# 	min =  @candidateConstList[col]['min']
	# 	max = @candidateConstList[col]['max']
	# 	case opr
	# 	when '>', '>='
	# 		newVal = min
	# 	when '<', '<='
	# 		newVal = max
	# 	# when '='
	# 	else
	# 		randVal = rand(2)
	# 		newVal = randVal == 1 ? max : min
	# 	end
	# end
	# def generate_candiateList(predicate)
	# 	fromPT = @fqueryObj['parseTree']['SELECT']['fromClause']
	# 	@column = JsonPath.on(predicate, '$..COLUMNREF.fields').to_a()[0]
	# 	@opr = JsonPath.on(predicate, '$..AEXPR.name').to_a()[0]
	# 	@const = JsonPath.on(predicate, '$..A_CONST.val').to_a()[0]
	# 	@candidateColList = DBConn.findRelFieldListByCol(fromPT, @column)
	# 	# # remove @column from candidateColList
	# 	# oldColIdx =@candidateColList.find_index do |item|
	# 	# 				if @column.count>1
	# 	# 					@column.join('.') == "#{item.relalias}.#{item.colname}"
	# 	# 				else
	# 	# 					@column[0] == item.colname
	# 	# 				end
	# 	# 			end
	# 	# @candidateColList.delete_at(oldColIdx)
	# 	# @candidateOprList = @oprSymbols[@opr[0]]
	# 	@candidateOprList = @oprSymbols

	# end
	# def generate_candidateConstList()
	# 	@candidateConstList =Hash.new()
	# 	columns = @candidateColList.clone
	# 	columns.each do |col|
	# 		colVal = Hash.new()
	# 		['min','max'].each do |type|
	# 			val = get_min_max_val(col,type)
	# 			colVal.merge!( val)
	# 		end
	# 		@candidateConstList[col.colname] = colVal
	# 	end
	# end
	# def get_min_max_val(column,type)
	# 	# find correct pks (Union of missing pk and satisfied pk)
	# 	# for now we get them from t_result
	# 	rewriteCols = Hash.new()

	# 	pkquery = "select #{@pk} from t_result"
	# 	parseTree= @fqueryObj['parseTree']
	# 	fromPT = @fqueryObj['parseTree']['SELECT']['fromClause']
	# 	fields = DBConn.getAllRelFieldList(fromPT)
	# 	# remove the where clause in query
	# 	whereClauseReplacement = Array.new()
	# 	query_with_no_whereClause =  ReverseParseTree.reverseAndreplace(parseTree, '',whereClauseReplacement)
		
	# 	# rewrite the query to return all fields
	# 	query_with_no_whereClause,rewriteCols = RewriteQuery.return_all_fields(query_with_no_whereClause)
	# 	pkjoin = @pk.split(',').map do |pkcol| 
	# 				if rewriteCols.has_key?(pkcol) 
	# 					t_pkcol = "t.#{pkcol}"
	# 				else
	# 					t_pkcol = "t.#{pkcol}"
	# 				end
	# 				"pk.#{pkcol} = #{t_pkcol}" 
	# 			end.join(' AND ')
	# 	col = if rewriteCols.has_key?(column.colname) 
	# 			"t.#{column.relname}_#{column.colname}"
	# 		else
	# 			"t.#{column.colname}"
	# 		end
	# 	# fromPT = @fqueryObj['parseTree']['SELECT']['fromClause']		
	# 	query = "with pk as (#{pkquery}), t as (#{query_with_no_whereClause}) 
	# 			select #{type}(#{col})  from t join pk on #{pkjoin}"

	# 	# pp query
	# 	rst = DBConn.exec(query)
	# 	rst[0]
	# 	# pp rst[0]

	# end

end
