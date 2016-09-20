require 'json'
require 'pp'
require 'pg'
require 'jsonpath'
require 'rubytree'
require_relative 'string_util'
require_relative 'query_builder'
module ReverseParseTree

  def ReverseParseTree.reverse(parseTree)
    #distinct = parseTree['SELECT']['distinctClause']||''
    distinct = parseTree['SELECT']['distinctClause'].kind_of?(Array) ? 'DISTINCT ' : ''
    #p parseTree['SELECT']['distinctClause']
    # p "Distinct: #{distinct}"
    targetList = parseTree['SELECT']['targetList'].map do  |t|
      colNameConstr(t)['fullname']
    end.join(', ')
     # p "targetList: #{targetList}"

    fromPT = parseTree['SELECT']['fromClause']
    fromClause = fromClauseConstr(fromPT)
     # p "fromClause: #{fromClause}"
    wherePT = parseTree['SELECT']['whereClause']
    whereClause = whereClauseConst(wherePT)
     # p "WhereClause: #{whereClause}"

    query = 'SELECT '+ distinct + targetList +
            ' FROM ' + fromClause+
             ( whereClause.length == 0? '' : ' WHERE '+ whereClause)

  end

  # replace select target list in query with replacement
  def ReverseParseTree.reverseAndreplace(parseTree, targetListReplacement, whereClauseReplacement)
 #distinct = parseTree['SELECT']['distinctClause']||''
    distinct = parseTree['SELECT']['distinctClause'].kind_of?(Array) ? 'DISTINCT ' : ''
    #p parseTree['SELECT']['distinctClause']
    if targetListReplacement.to_s.empty?
      targetList = parseTree['SELECT']['targetList'].map do  |t|
        colNameConstr(t)['fullname']
      end.join(', ')
    else
      targetList = targetListReplacement
    end
    fromPT = parseTree['SELECT']['fromClause']
    fromClause = fromClauseConstr(fromPT)
    wherePT = parseTree['SELECT']['whereClause']

    whereClause = whereClauseReplacement.to_s.empty? ? whereClauseConst(wherePT) : whereClauseReplacement
    query = 'SELECT '+ distinct + targetList +
            ' FROM ' + fromClause+
             ( whereClause.length == 0? '' : ' WHERE '+ whereClause)

  end


  # construct relname from relname and rel alias
  def ReverseParseTree.relnameConstr(rel)
    #pp rel
    #pp rel['RANGEVAR']['alias']
    relalias =  rel['alias'].nil? ? '': "#{rel['alias']['ALIAS']['aliasname']}"
    relname = rel['relname']#+relalias
    rst = Hash.new()
    rst['relname'] = relname
    rst['alias'] = relalias
    rst['fullname'] =  rel['alias'].nil? ? relname : "#{relname} #{relalias}"
    rst
    # p relname
  end
  def ReverseParseTree.colNameConstr(t)
      rst = Hash.new()

      # p t['RESTARGET']
      rst['col'] = t['RESTARGET']['val']['COLUMNREF'].nil? ? whereClauseConst(t['RESTARGET']['val']) : t['RESTARGET']['val']['COLUMNREF']['fields'].join('.')
      rst['alias'] = t['RESTARGET']['name'].nil? ? (( t['RESTARGET']['val']['COLUMNREF']['fields'].count()==1 ) ? t['RESTARGET']['val']['COLUMNREF']['fields'][0] : t['RESTARGET']['val']['COLUMNREF']['fields'][1]) : "#{t['RESTARGET']['name']}"
      # rst['fullname'] = rst['alias'].length==0 ? rst['col'] : "#{rst['col']} AS #{rst['alias']}"
      # p rst['alias']
      # p rst['col'] 
      rst['fullname'] = "#{rst['col']} AS #{rst['alias']}"
      # p rst['fullname'] 
      rst
  end

  # construct expression
  def self.exprConstr(expr)
    unless expr['A_CONST'].nil?
      constVal = expr['A_CONST']['val']
      #p constVal
      #p is_integer?(constVal)
      constVal = constVal.to_s.str_int_rep
    end
    expr['COLUMNREF'].nil? ?  constVal : expr['COLUMNREF']['fields'].join('.')
  end

  # recursively construct Join Arg
  def self.recursiveJoinArg(arg)
    if arg['JOINEXPR'].nil?
      arg = relnameConstr(arg['RANGEVAR'])['fullname']
    else
      arg = joinClauseConstr(arg)
    end
    arg
  end

  # join clause construct
  def self.joinClauseConstr(join)
      #pp join
      #p join['JOINEXPR']['jointype']
      jointype = joinTypeConvert( join['JOINEXPR']['jointype'].to_s, join['JOINEXPR']['quals'] )
      #p jointype
      larg = recursiveJoinArg(join['JOINEXPR']['larg'])
      rarg = recursiveJoinArg(join['JOINEXPR']['rarg'])
      quals = join['JOINEXPR']['quals'].nil? ?  "" : "ON "+ whereClauseConst(join['JOINEXPR']['quals'])
      joinClause = "#{larg} #{jointype} #{rarg} #{quals}"
  end

  def ReverseParseTree.joinTypeConvert(joinType, quals)
    case joinType
        when '0'
          quals.nil? ? 'CROSS JOIN' : 'JOIN'
        when '1'
          'LEFT JOIN'
        when '2'
          'FULL JOIN'
        when '3'
          'RIGHT JOIN'
        else
          'JOIN'
    end
  end


  # where clause construct
  def ReverseParseTree.whereClauseConst(where)
    # pp where
    if where.nil?
      return ''
    end
    if where.kind_of?(Array)
      exprArray =[]
      where.each do |w|
        exprArray <<whereClauseConstr_sub(w)
      end
      expr = "'"+exprArray.join(',')+"'"
      # p expr
    else
      expr = whereClauseConstr_sub(where)
    end
  end

  def ReverseParseTree.whereClauseConstr_sub(where)
    logicOpr = where.keys[0].to_s
    lexpr = where[logicOpr]['lexpr']
    rexpr = where[logicOpr]['rexpr']
    if logicOpr == 'AEXPR' 
      op = where[logicOpr]['name'][0]
      lexpr = lexpr.keys[0].to_s == 'AEXPR'? whereClauseConst(lexpr) : exprConstr(lexpr)
      rexpr = rexpr.keys[0].to_s == 'AEXPR'? whereClauseConst(rexpr) : exprConstr(rexpr)
      expr = lexpr.to_s + ' '+ op +' '+ rexpr.to_s
    elsif logicOpr == 'NULLTEST'
      # binding.pry
      colname =  exprConstr( where[logicOpr]['arg'] )
      op = where[logicOpr]['nulltesttype'] == 1 ? ' IS NOT NULL' : ' IS NULL'
      expr = colname+ op
    elsif logicOpr == 'AEXPR IN'
      op = where[logicOpr]['name'][0] == '<>' ? 'NOT IN' : 'IN'
      lexpr = lexpr.keys[0].to_s == 'AEXPR'? whereClauseConst(lexpr) : exprConstr(lexpr)
      rexpr = rexpr.map do |val|
                exprConstr(val)
              end.join(',')
      expr = lexpr.to_s + ' '+ op +' ('+ rexpr.to_s+' )'
    elsif logicOpr == 'A_CONST'
      exprConstr(where)
    else
      lexpr = whereClauseConst(lexpr)
      rexpr = whereClauseConst(rexpr)
      logicOpr = logicOpr.gsub('AEXPR ','')

      expr = ( logicOpr == 'OR' ? '( ':'' ) +
             lexpr + ' ' +
             # ( logicOpr == 'OR' ? ') ':'') +
             logicOpr + ' ' +
             # ( logicOpr == 'OR' ? '( ':'' ) +
              rexpr +
              ( logicOpr == 'OR' ? ' )':'')
    end
  end
  # def self.is_integer?(str)
  #   str.to_s.to_i.to_s == str.to_s
  # end

  # def ReverseParseTree.whereCondSplit(wherePT)
  #   result = []
  #   #pp wherePT
  #   logicOpr = wherePT.keys[0].to_s
  #   #p logicOpr
  #   if ( logicOpr == 'AEXPR AND' or logicOpr == 'AEXPR OR')
  #     result += whereCondSplit(wherePT[logicOpr]['lexpr'])
  #     result += whereCondSplit(wherePT[logicOpr]['rexpr'])
  #   # or operator are tested as a whole 
  #   else 
  #     h =  Hash.new
  #     h['query'] = whereClauseConst(wherePT)
  #     pp wherePT
  #     h['location'] = wherePT[logicOpr]['location']
  #     h['suspicious_score'] = 0
  #     h['columns'] = columnsInPredicate(wherePT)
  #     result << h
  #   end
  #   #pp result.to_a
  #   result
  # end
  def ReverseParseTree.columnsInPredicate(expr)
    columns = []
    #pp wherePT
    logicOpr = expr.keys[0].to_s
    if logicOpr == 'AEXPR'
      columns += columnsInPredicate(expr[logicOpr]['lexpr'])
      columns += columnsInPredicate(expr[logicOpr]['rexpr'])
    # or operator are tested as a whole
    elsif logicOpr == 'AEXPR IN'
      columns += columnsInPredicate(expr[logicOpr]['lexpr'])
    elsif logicOpr == 'NULLTEST'
      columns += columnsInPredicate(expr[logicOpr]['arg'])
    else
      unless expr['COLUMNREF'].nil?
        # col = expr['COLUMNREF']['fields'].join('.')
        columns << expr['COLUMNREF']['fields']
      end
    end
    # pp columns
    columns
  end
  def ReverseParseTree.fromClauseConstr(fromPT)
    # pp fromPT
    # abort('test')
    if fromPT[0]['JOINEXPR'].nil?
      fromClause = relnameConstr(fromPT[0]['RANGEVAR'])['fullname']
    else
      fromClause = joinClauseConstr(fromPT[0])
    end
  end

  def ReverseParseTree.find_col_by_name(targetList, colName)
    node = Hash.new()
    targetList.each do |t|
      node = colNameConstr(t)
      if ( node['alias'] == colName or node['col'].split('.').include?(colName))
        node
        break
      end
    end
    node
  end
  # def ReverseParseTree.predicate_tree_const(wherePT)
  #   # if cnt ==0
  #   #   nodeName= 'root'
  #   #   curNode = Tree::TreeNode.new(nodeName, '')
  #   # end
  #   # curNode = Tree::TreeNode.new(nodeName, '')
  #   logicOpr = wherePT.keys[0].to_s
  #   #p logicOpr
  #   if logicOpr == 'AEXPR AND' 
  #     lexpr = predicate_tree_const(lexpr) 
  #     rexpr = predicate_tree_const(rexpr)
  #     curNode<<lexpr<<rexpr
  #   # or operator are tested as a whole 
  #   elsif logicOpr == 'AEXPR OR'
  #     lexpr = predicate_tree_const(lexpr) 
  #     rexpr = predicate_tree_const(rexpr) 
  #     curNode<<lexpr
  #     curNode<<rexpr
  #   else 
  #     # nodeName= "P#{cnt+1}"
  #     # cnt= cnt+1
  #     h =  Hash.new
  #     h['query'] = whereClauseConst(wherePT)
  #     # pp wherePT
  #     h['location'] = wherePT[logicOpr]['location']
  #     h['suspicious_score'] = 0
  #     curNode=Tree::TreeNode.new(h['location'], h)
  #   end
  #   #pp result.to_a
  #   curNode
  # end

end