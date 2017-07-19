require 'jsonpath'
require 'pp'
require_relative 'acyclic_graph'
require_relative 'reverse_parsetree'

module AutoFix
  # Find all the relations(tbls) from FROM Clause including their columns
  def self.JoinTypeFix(joinErrList, parseTree)
    fromPT = parseTree['SELECT']['fromClause'][0]
    joinErrList.each do |err|
      loc = err['location']
      joinSide = err['joinSide']
      joinType = err['joinType']
      if (joinType.to_s == '1') && (joinSide == 'R')
        # the fix would be change join from Left JOin to Inner Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '0')  }.to_hash
      # left Join, L side null is missing
      elsif (joinType.to_s == '1') && (joinSide == 'L')
        # the fix would be change join from Left JOin to FULL Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '3')  }.to_hash
      # left Join, L side null is missing  and R side null is unwanted
      elsif (joinType.to_s == '1') && (joinSide == 'L,R')
        # the fix would be change join from Left JOin to RIGHT Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '2')  }.to_hash
      # right Join, l side null is unwanted
      elsif (joinType.to_s == '2') && (joinSide == 'L')
        # the fix would be change join from Left JOin to Inner Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '0')  }.to_hash
      # right Join, R side null is unwanted
      elsif (joinType.to_s == '2') && (joinSide == 'L')
        # the fix would be change join from Left JOin to FULL Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '3')  }.to_hash
      # right Join, R side null is missing  and L side null is unwanted
      elsif (joinType.to_s == '2') && (joinSide == 'L,R')
        # the fix would be change join from Left JOin to LEFT Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '1')  }.to_hash
      # inner join, R side null is missing
      elsif (joinType.to_s == '0') && (joinSide == 'R')
        # the fix would be change join from INNERT JOin to LEFT Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '1')  }.to_hash
      # inner join, L side null is missing
      elsif (joinType.to_s == '0') && (joinSide == 'L')
        # the fix would be change join from INNERT JOin to RIGHT Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '2')  }.to_hash
      # inner join, L,R side null are missing
      elsif (joinType.to_s == '0') && (joinSide == 'L,R')
        # the fix would be change join from INNERT JOin to FULL Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '3')  }.to_hash

      end
    end
    fromPTArry = []
    fromPTArry << fromPT
    JsonPath.for(parseTree).gsub('$..fromClause') { |_v| fromPTArry }.to_hash
   end

  def self.update_joinType_by_loc(json, loc, new_val)
    JsonPath.on(json, '$.rarg.RANGEVAR.location')[0] == loc ? JsonPath.for(json).gsub('$.jointype') { |_v| new_val }.to_hash : json
  end

  def self.whereCondFix(_wherePT)
    query = 'select node_name,query,columns,suspicious_score '\
           'from node_query_mapping '\
           'where suspicious_score >0'
    predicateList = PredicateUtil.get_predicateList(query)

    predicateList.each do |predicate|
      location = predicate['location']
    end
  end

  def self.join_key_fix(join_key_list,parse_tree)
    # join_rels = JsonPath.on(parse_tree['SELECT']['fromClause'][0]['JOINEXPR'].to_json, '$..relname')
    join_rels = ReverseParseTree.rel_in_from(parse_tree['SELECT']['fromClause'])
    binding.pry
    from_query = 'FROM '
    ag = AcyclicGraph.new([])

    0.upto(join_rels.count-2) do |i|
      l_rel = join_rels[i]
      r_rel = join_rels[i+1]
      from_query = from_query + (i==0 ? "#{l_rel['relname']} #{l_rel['relalias']}" : "")+ " JOIN #{r_rel['relname']} #{r_rel['relalias']} on "
      jk =  join_key_list.select do |kp|
                          rels = kp.map{|k| k.relname}
                          col_id_list = kp.map{|k| k.object_id}
                          rels.include?(l_rel['relname']) && rels.include?(r_rel['relname']) && ag.add_edge(col_id_list)
                        end
      q = jk.map do |kp|
                        kp.map{|k| "#{k.fullname}"}.join(" = ")
          end.join(" AND ")
      from_query = from_query + q
    end
    # pp from_query
    from_query
  end
end
