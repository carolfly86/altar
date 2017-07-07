require 'jsonpath'
require_relative 'reverse_parsetree'
require_relative 'db_connection'
require_relative 'array_helper'
class SqlMutation
  def initialize(parseTree)
    @ps = parseTree
    @selectionList = @ps['SELECT']['targetList']
    @fromPT =  @ps['SELECT']['fromClause']
    @fieldList = DBConn.getAllRelFieldList(@fromPT)
    @typcategoryList = %w(U N B S)
    @eqSymbols = ['=', '>', '<', '<>', '>=', '<=']
    @joinTypes = %w(0 1 2 3 4)

    # pp @ps
  end

  def sel_scMutation
    newPS = @ps
    distinctClause = @ps['SELECT']['distinctClause']
    newPS['SELECT']['distinctClause'] = distinctClause.is_a?(Array) ? nil : [nil]
    pp newPS
    ReverseParseTree.reverse(newPS)
  end

  def join_scMutation
    newPS = @ps
    joinExpr = @ps['SELECT']['fromClause'][0]['JOINEXPR']

    oldQuals = joinExpr['quals']
    # if Cross join, we define join type as 4
    oldJoinType = oldQuals.nil? ? '4' : joinExpr['jointype']
    newJoinType = @joinTypes.find_random_dif(oldJoinType)
    newQuals = oldQuals
    newQuals = nil if newJoinType == '4'
    newQuals = generate_rand_equation(0, false) if oldJoinType == '4'
    newPS['SELECT']['fromClause'][0]['JOINEXPR']['jointype'] = newJoinType
    newPS['SELECT']['fromClause'][0]['JOINEXPR']['quals'] = newQuals
    ReverseParseTree.reverse(newPS)
    # pp "newQuals: #{newQuals}"
  end

  # mutation for the operators
  def oprMutation(jsonParseTree)
    # jsonParseTree = @ps
    muParseTree = jsonParseTree
    aexprList = JsonPath.on(jsonParseTree, '$..AEXPR')

    unless aexprList.count == 0
      aexpr = aexprList[rand(aexprList.size)]
      oldOpr = aexpr['name'][0]
      p aexpr
      p oldOpr
      mutant = aexpr
      newOpr = @eqSymbols.find_random_dif(oldOpr)
      p "newOpr: #{newOpr}"
      mutant['name'][0] = newOpr
      muParseTree = JsonPath.for(jsonParseTree).gsub('$..AEXPR') { |v| (v['name'][0] == oldOpr ? mutant : v) }.to_hash
    end
    ReverseParseTree.reverse(muParseTree)
  end

  def constMutation(jsonParseTree)
    # jsonParseTree = @ps
    muParseTree = jsonParseTree
    constList = JsonPath.on(jsonParseTree, '$..A_CONST')
    unless constList.count == 0
      constant = constList[rand(constList.size)]
      oldVal = constant['val']
      datatypeCategory = oldVal.to_s.typCategory
      p constant
      p oldVal
      mutant = constant
      # rand = generate_rand_constant(datatypeCategory)
      newVal = generate_rand_constant(datatypeCategory)
      p "newval: #{newVal}"
      mutant['val'] = newVal
      muParseTree = JsonPath.for(jsonParseTree).gsub('$..A_CONST') { |v| (v['val'] == oldVal ? mutant : v) }.to_hash
    end
    muParseTree
    ReverseParseTree.reverse(muParseTree)
  end

  def colMutation(jsonParseTree)
    # jsonParseTree = @ps
    muParseTree = jsonParseTree
    colList = JsonPath.on(jsonParseTree, '$..COLUMNREF')
    pp colList
    unless colList.count == 0
      col = colList[rand(colList.size)]
      mutant = generate_rand_col(@fieldList, col)
      muParseTree = JsonPath.for(jsonParseTree).gsub('$..COLUMNREF') { |v| (v['fields'] == col['fields'] ? mutant : v) }.to_hash
    end
    muParseTree
    ReverseParseTree.reverse(muParseTree)
  end

  def generate_rand_equation(type = nil, is_expr = false)
    expr_max_depth = 1
    eqSymbol = @eqSymbols[rand(@eqSymbols.size)]

    typCategory = @typcategoryList[rand(@typcategoryList.length)]

    if is_expr
      larg = generate_rand_expr(expr_max_depth, 0, typCategory)
      rarg = generate_rand_expr(expr_max_depth, 0, typCategory)
    else
      puts typCategory
      args = generate_lr_terms(type, typCategory, @fieldList)
      larg = args[0]
      rarg = args[1]
    end
    r = {}
    r['name'] = []
    r['name'] << eqSymbol
    r['lexpr'] = larg
    r['rexpr'] = rarg
    equ = {}
    equ['AEXPR'] = r
    equ
  end

  def generate_rand_expr(max_depth, depth = 0, datatypeCategory = nil)
    numericOperators = ['+', '-', '*', '/']
    opr = numericOperators[rand(numericOperators.size)]
    fieldList = @fieldList
    if (depth == max_depth - 1) || rand < 0.5
      args = generate_lr_terms(datatypeCategory, @fieldList)
      larg = args[0]
      rarg = args[1]
      # return r
    else
      depth += 1
      larg = generate_rand_expr(max_depth, depth, datatypeCategory)
      rarg = generate_rand_expr(max_depth, depth, datatypeCategory)
    end
    r = {}
    r['name'] = []
    r['name'] << opr
    r['lexpr'] = larg
    r['rexpr'] = rarg
    expr = {}
    expr['AEXPR'] = r
    expr
  end

  def generate_lr_terms(type = nil, targetTpyCategory, fieldList)
    p type
    larg = generate_rand_term(type, targetTpyCategory, nil, fieldList)

    # if left is a column then right must be in matching typeCategory
    rFieldList = fieldList
    # Avoid left and right arg are the same colum
    rarg = generate_rand_term(type, targetTpyCategory, larg['COLUMNREF'], rFieldList)
    # divide by 0 is replaced by 1
    unless rarg['A_CONST'].nil? || rarg['A_CONST']['val'].to_s != '0' || opr != '/'
      rarg['A_CONST']['val'] = '1'
       end
    [larg, rarg]
  end

  def generate_rand_term(type = nil, datatypeCategory = nil, oldTerm = nil, fieldList)
    type = type.nil? ? rand(2) : type
    # if rand = 0 , return a field
    r = {}
    term = {}
    candidateFileds = datatypeCategory.to_s == '' ? fieldList : fieldList.select { |f| f.typcategory == datatypeCategory }
    if (type == 0) && !candidateFileds.empty?
      p oldTerm
      term['COLUMNREF'] = generate_rand_col(candidateFileds, oldTerm)
      # typCategory = field['typcategory']
    else
      # else return a constant
      r['val'] = generate_rand_constant(datatypeCategory)
      term['A_CONST'] = r
    end
    term
  end

  def generate_rand_constant(datatypeCategory)
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

  def generate_rand_col(fieldList, oldCol)
    p "oldVal: #{oldCol}"
    oldVal = Column.new
    oldVal.colname = oldCol.nil? ? nil : oldCol['fields'][1]
    oldVal.relalias = oldCol.nil? ? nil : oldCol['fields'][0]
    mutant = oldCol.nil? ? {} : oldCol
    newVal = fieldList.find_random_dif(oldVal) # get_rand_col(@fieldList,col['fields'])
    mutant['fields'] = []
    mutant['fields'] << newVal.relalias
    mutant['fields'] << newVal.colname
    p "newval: #{mutant}"
    mutant
  end
end
