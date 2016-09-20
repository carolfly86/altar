
require 'jsonpath'
require_relative 'reverse_parsetree'
require_relative 'db_connection'
require_relative 'random_gaussian'
class GeneticAlg
# Genetic Programming in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.
	def initialize(parseTree)
		@max_gens = 100
	    @max_depth = 4
	    @expr_max_depth = 2
	    @pop_size = 100
	    @bouts = 5
	    @p_repro = 0.08
	    @p_cross = 0.90
	    @p_mut = 0.02
	    @numericOperators = ['+', '-', '*', '/']
	    @keywords = [ 'AND', 'NOT', 'OR', '']
	    @eqSymbols= ['=', '>', '<','<>']
	    @ps = parseTree
	    @fromPT =  @ps['SELECT']['fromClause']
	    @fieldsList = DBConn.getRelFieldList(@fromPT)
	    @numericDataTypes = ['smallint','integer','bigint','decimal','numeric','real','double precision','serial','bigserial']
	    pp @fieldsList
	    # @parentAEXPR =0

	end
	def generate_random_program(depth=0 )
	  aexpr = @keywords[rand(@keywords.size)] 
	  if depth==@max_depth-1 or aexpr == ''
	    return generate_rand_equation()
	  end  
	  depth += 1 
	  p depth
	  larg = ( aexpr== 'NOT'? nil : generate_random_program( depth) )
	  rarg = generate_random_program( depth)
	  r = Hash.new()
	  r['lexpr'] = larg
	  r['rexpr'] = rarg
	  expr = Hash.new()
	  expr["AEXPR #{aexpr}"] = r
	  return expr
	end
	def generate_neighbor_program(parseTree)
		# neighborPS = parseTree
		mutateType = rand(3)
		neighborPS = mutateColumn(parseTree)
		# if mutateType == 0
		# 	neighborPS = mutateConstant(parseTree)
		# elsif mutateType == 1
		# 	neighborPS = mutateColumn(parseTree)
		# elsif mutateType == 2
		# 	neighborPS = mutateOperator(parseTree)
		# end
		pp neighborPS			

	end

	def mutateConstant(parseTree)
		jsonParseTree = parseTree
		muParseTree =parseTree
		constList = JsonPath.on(jsonParseTree, '$..A_CONST')
		unless constList.count()==0
			constant = constList[rand(constList.size)]
			oldVal = constant['val'].to_i
			p constant
			p oldVal
			mutant = constant
			rand = rand_in_bounds(-10,10)
			while rand == constant['val'].to_i
				rand = rand_in_bounds(-10,10)
			end
			newVal = rand
			p "newval: #{newVal}"
			mutant['val'] = newVal
			muParseTree = JsonPath.for(jsonParseTree).gsub("$..A_CONST") {|v| ( v['val'] == oldVal ? mutant : v) }
		end
		muParseTree 
	end

	def mutateColumn(parseTree)
		jsonParseTree = parseTree
		muParseTree =parseTree
		colList = JsonPath.on(jsonParseTree, '$..COLUMNREF')
		unless colList.count()==0
			col = colList[rand(colList.size)]
			oldVal = col['fields']
			p col
			mutant = col
			rand = @fieldsList[rand(@fieldsList.size)]
			while rand == col
				rand = @fieldsList[rand(@fieldsList.size)]
			end
			newVal = rand
			p "newval: #{newVal}"
			mutant['fields'] = newVal
			muParseTree = JsonPath.for(jsonParseTree).gsub("$..COLUMNREF") {|v| ( v['fields'] == oldVal ? mutant : v) }
		end
		muParseTree 
	end
	def mutateOperator(parseTree)
	end	
	# rand generate should be based on some statistic of the data set?
	# Could use gaussian rand generation :
	# g = RandomGaussian.new(0,1)
	# g.rand
	private 

	def rand_in_bounds(min, max)
		return  (min + (max-min)*rand()).to_i
	end



	# def generate_rand_aexpr()
	# 	# if rand = 0 , return a key work
	# 	if rand(2) == 0
	# 		aexpr = @keywords[rand(@keywords.size)] 
	# 		parentAEXPR = 0
	# 	else
	# 		aexpr = @eqSymbols[rand(@eqSymbols.size)] 
	# 		parentAEXPR = 1
	# 	end
	# 	return aexpr, parentAEXPR
	# end

	def generate_rand_equation()
		eqSymbol = @eqSymbols[rand(@eqSymbols.size)] 
		larg = generate_rand_expr(@expr_max_depth )
		rarg = generate_rand_expr(@expr_max_depth )
		r = Hash.new()
		r['name'] = []
	  	r['name'] << eqSymbol
	    r['lexpr'] = larg
	    r['rexpr'] = rarg
	    equ = Hash.new()
	  	equ['AEXPR'] = r
	  	return equ
	end

	def generate_rand_expr(max_depth, depth=0 )
	  opr = @numericOperators[rand(@numericOperators.size)] 		
	  if depth==max_depth-1 or rand()< 0.5
	    larg = generate_rand_term()
	    rarg = generate_rand_term()
	    # divide by 0 is replaced by 1
	    unless rarg['A_CONST'].nil? || rarg['A_CONST']['val'].to_s !='0' || opr != '/'
	    	rarg['A_CONST']['val']= '1'
	    end
	    #return r	   
	  else
		  depth += 1 
		  larg = generate_rand_expr(max_depth, depth)
		  rarg = generate_rand_expr(max_depth, depth)
	  end 
	  r = Hash.new()
	  r['name'] =[]
	  r['name'] << opr
	  r['lexpr'] = larg
	  r['rexpr'] = rarg
	  expr = Hash.new()
	  expr['AEXPR'] = r
	  return expr
	end

	def generate_rand_term()
		# if rand = 0 , return a field
		r = Hash.new()
		term = Hash.new()
		if rand(2) == 0
			#term = 
			r['fields'] = @fieldsList[rand(@fieldsList.size)] 
			term['COLUMNREF'] = r
		else
			#else return a constant
			r['val'] = rand_in_bounds(-10.0, +10.0).to_s
			term['A_CONST'] = r
		end
		term
	end
	def fitness(prog)
		ps = @ps
		ps['SELECT']['whereClause'] = prog
		query =  ReverseParseTree.reverse(ps)
	end
	def search
		population = Array.new(@pop_size) do |p|
    		{:prog=>generate_random_program()}
  		end
  		population.each{|c| c[:fitness] = fitness(c[:prog])}
	end


end


