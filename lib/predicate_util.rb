module PredicateUtil
	def PredicateUtil.get_predicateList(query,fromPT)
		# pp query
		res=DBConn.exec(query)

		pcList = Array.new()
		num_fields=res.num_fields()
		res.each do |r|
			colsList=[]
			# Convert each column to Column Obj
			r['columns'].to_s.gsub(/[\{\}]/,'').split(',').each do |c|
				col=c.split('.')
				column=Column.new
				if col.count()>1
					# column.relalias = col[0]
					column.colname = col[1]
					column.updateRelname(fromPT)
					# column.relname=''
				else
					column.colname=col[0]
					column.updateRelname(fromPT)
					# column.relname=''
					# column.relalias=''
				end

				colsList<<column
			end
			r['columns']=colsList
			pcList<<r
		end
		pcList

	end
	def PredicateUtil.get_predicateQuery(predicateList)
		# logicOpr = type=='U' ? 'AND' : 'OR'

		predicateQuery=''
		branches = predicateList.map{|p| p['branch_name']}.uniq
		queryBranches = Array.new()
		branches.each do |b|
			branch = Array.new()
			predicateList.find_all_hash('branch_name',b).each do |n|
				branch<<n['query']
			end
			branchQuery = '('+branch.join(' AND ')+')'
			queryBranches << branchQuery unless queryBranches.include?(branchQuery)
		end
		predicateQuery = queryBranches.join(' OR ')
		# pp predicateQuery
		return predicateQuery
	end
	def PredicateUtil.get_predicateColumns(predicateList)
		columnList=Array.new()
		predicateList.each do |p|
			columnList += p['columns']
		end
		columnList.uniq
	end


	def PredicateUtil.column_str_constr(columnList)
		columnList.map do |c| 
			c.expr
		end.join(',')
	end
end