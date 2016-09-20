require 'jsonpath'
require 'pp'
module AutoFix
	# Find all the relations(tbls) from FROM Clause including their columns
  def AutoFix.JoinTypeFix(joinErrList,parseTree)
      
      fromPT = parseTree['SELECT']['fromClause'][0]
    	joinErrList.each do |err|
      		loc = err['location']
          joinSide = err['joinSide']
          joinType = err['joinType']
          case 
          # left Join, R side null is unwanted  
          when ( joinType.to_s =='1' and joinSide == 'R'  )
            # the fix would be change join from Left JOin to Inner Join
            fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR'){|v| update_joinType_by_loc(v,loc,'0')  }.to_hash
          # left Join, L side null is missing  
          when ( joinType.to_s =='1' and joinSide == 'L'  )
            # the fix would be change join from Left JOin to FULL Join
            fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR'){|v| update_joinType_by_loc(v,loc,'3')  }.to_hash
          # left Join, L side null is missing  and R side null is unwanted
          when ( joinType.to_s =='1' and joinSide == 'L,R'  )
            # the fix would be change join from Left JOin to RIGHT Join
            fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR'){|v| update_joinType_by_loc(v,loc,'2')  }.to_hash
          # right Join, l side null is unwanted  
          when ( joinType.to_s =='2' and joinSide == 'L'  )
            # the fix would be change join from Left JOin to Inner Join
            fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR'){|v| update_joinType_by_loc(v,loc,'0')  }.to_hash
          # right Join, R side null is unwanted  
          when ( joinType.to_s =='2' and joinSide == 'L'  )
            # the fix would be change join from Left JOin to FULL Join
            fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR'){|v| update_joinType_by_loc(v,loc,'3')  }.to_hash
          # right Join, R side null is missing  and L side null is unwanted
          when ( joinType.to_s =='2' and joinSide == 'L,R'  )
            # the fix would be change join from Left JOin to LEFT Join
            fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR'){|v| update_joinType_by_loc(v,loc,'1')  }.to_hash
          # inner join, R side null is missing  
          when (joinType.to_s == '0' and joinSide == 'R')  
            # the fix would be change join from INNERT JOin to LEFT Join
            fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR'){|v| update_joinType_by_loc(v,loc,'1')  }.to_hash
          # inner join, L side null is missing  
          when (joinType.to_s == '0' and joinSide == 'L')  
            # the fix would be change join from INNERT JOin to RIGHT Join
            fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR'){|v| update_joinType_by_loc(v,loc,'2')  }.to_hash
          # inner join, L,R side null are missing  
          when (joinType.to_s == '0' and joinSide == 'L,R')  
            # the fix would be change join from INNERT JOin to FULL Join
            fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR'){|v| update_joinType_by_loc(v,loc,'3')  }.to_hash

          end


    	end 
      fromPTArry = []
      fromPTArry << fromPT
      JsonPath.for(parseTree).gsub('$..fromClause'){|v| fromPTArry}.to_hash

 	end

  def AutoFix.update_joinType_by_loc(json,loc, new_val)
    JsonPath.on(json, '$.rarg.RANGEVAR.location')[0] == loc ? JsonPath.for(json).gsub('$.jointype'){|v| new_val }.to_hash : json  
  end

  def AutoFix.whereCondFix(wherePT)

    query ="select node_name,query,columns,suspicious_score "+
        "from node_query_mapping "+
        "where suspicious_score >0"
    predicateList =PredicateUtil.get_predicateList(query)

    predicateList.each do |predicate|
      location=predicate['location']
    end
  end
end
