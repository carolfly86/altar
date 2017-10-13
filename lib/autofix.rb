require 'jsonpath'
require 'pp'
require_relative 'acyclic_graph'
require_relative 'reverse_parsetree'
require_relative 'test_result_detail'
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
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '2')  }.to_hash
      # left Join, L side null is missing  and R side null is unwanted
      elsif (joinType.to_s == '1') && (joinSide == 'L,R')
        # the fix would be change join from Left JOin to RIGHT Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '3')  }.to_hash
      # RIGHT JOIN FIX
      elsif (joinType.to_s == '3') && (joinSide == 'R')
        # the fix would be change join from RIGHT JOin to FULL Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '2')  }.to_hash
      # left Join, L side null is missing
      elsif (joinType.to_s == '3') && (joinSide == 'L')
        # the fix would be change join from Left JOin to INNER Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '0')  }.to_hash
      # left Join, L side null is missing  and R side null is unwanted
      elsif (joinType.to_s == '3') && (joinSide == 'L,R')
        # the fix would be change join from Left JOin to LEFT Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '1')  }.to_hash
      # FULL Join, l side null is unwanted
      elsif (joinType.to_s == '2') && (joinSide == 'L')
        # the fix would be change FULL join from FULL JOin to LEFT Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '1')  }.to_hash
      # FULL Join, R side null is unwanted
      elsif (joinType.to_s == '2') && (joinSide == 'R')
        # the fix would be change join from FULL JOin to RIGHT Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '3')  }.to_hash
      # FULL Join, R side null is missing  and L side null is unwanted
      elsif (joinType.to_s == '2') && (joinSide == 'L,R')
        # the fix would be change join from Left JOin to LEFT Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '0')  }.to_hash
      # inner join, R side null is missing
      elsif (joinType.to_s == '0') && (joinSide == 'R')
        # the fix would be change join from INNERT JOin to LEFT Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '1')  }.to_hash
      # inner join, L side null is missing
      elsif (joinType.to_s == '0') && (joinSide == 'L')
        # the fix would be change join from INNERT JOin to RIGHT Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '3')  }.to_hash
      # inner join, L,R side null are missing
      elsif (joinType.to_s == '0') && (joinSide == 'L,R')
        # the fix would be change join from INNERT JOin to FULL Join
        fromPT = JsonPath.for(fromPT).gsub('$..JOINEXPR') { |v| update_joinType_by_loc(v, loc, '2')  }.to_hash

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

  def self.join_key_fix(join_key_list,query_object)
    # join_rels = ReverseParseTree.rel_in_from(parse_tree['SELECT']['fromClause'])
    join_list = query_object.join_list()
    from_query = ''
    ag = AcyclicGraph.new([])
    new_join_key_list = Set.new()
    0.upto(join_list.count-1) do |i|
      break if join_key_list.count == 0
      join = join_list.find{|j| j['id'] ==i }
      l_rel_list = join['l_rel_list']
      r_rel = join['r_rel_list'][0]
      all_rels = join['l_rel_list'].map{|r| r.relname}
      all_rels << r_rel.relname
      has_quals = (not join['quals'].nil?)
      join_type = ReverseParseTree.joinTypeConvert(join['jointype'].to_s, has_quals)

      l_arg = (i==0 ? "#{l_rel_list[0].relname} #{l_rel_list[0].relalias}" : "")
      from_query = from_query + "#{l_arg} #{join_type} #{r_rel.relname} #{r_rel.relalias} on "
      jk =  join_key_list.select do |kp|
                          rels = kp.map{|k| k.relname}
                          rels_is_included = (rels - all_rels).empty?

                          col_id_list = kp.map{|k| k.hash}
                          ( rels_is_included && ag.add_edge(col_id_list) )
                        end
      if jk.count == 0
        # fail to find join key in new join key list
        # reuse old join key
        puts "fail to find new join keys from (#{all_rels.join(', ')}) !"
        quals = join['quals']
        q = ReverseParseTree.whereClauseConst(join['quals'])
      else
        new_join_key_list = new_join_key_list + jk
        join_key_list = join_key_list - jk

        q = jk.map do |kp|
              kp.map{|k| "#{k.fullname}"}.join(" = ")
            end.join(" AND ")
      end

      from_query = from_query + q
    end

    # append remaining keys
    q = ""
    if join_key_list.count>0
      jk =  join_key_list.select do |kp|
                          rels = kp.map{|k| k.relname}
                          col_id_list = kp.map{|k| k.hash}
                          ag.add_edge(col_id_list)
                        end

      q = jk.map do |kp|
            kp.map{|k| "#{k.fullname}"}.join(" = ")
          end.join(" AND ")
      new_join_key_list = new_join_key_list + jk
    end
    from_query = from_query + (q == "" ? "": " AND ") + q
    pp from_query
    return from_query, new_join_key_list
  end


  def self.fix_from_query(query,new_from)
    binding.pry
    old_from = /\sfrom\s([\w\s\.\=\>\<\_\-]+)\s(where\s)?/i.match(query)[1]
    query.gsub(old_from,new_from)
  end
end
