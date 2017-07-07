module PredicateUtil
  def self.get_predicateList(query, fromPT)
    # pp query
    res = DBConn.exec(query)

    pcList = []
    num_fields = res.num_fields()
    res.each do |r|
      colsList = []
      # Convert each column to Column Obj
      r['columns'].to_s.gsub(/[\{\}]/, '').split(',').each do |c|
        col = c.split('.')
        column = Column.new
        if col.count > 1
          # column.relalias = col[0]
          column.colname = col[1]
          column.updateRelname(fromPT)
        # column.relname=''
        else
          column.colname = col[0]
          column.updateRelname(fromPT)
          # column.relname=''
          # column.relalias=''
        end

        colsList << column
      end
      r['columns'] = colsList
      pcList << r
    end
    pcList
  end

  def self.get_predicateQuery(predicateList)
    # logicOpr = type=='U' ? 'AND' : 'OR'

    predicateQuery = ''
    branches = predicateList.map { |p| p['branch_name'] }.uniq
    queryBranches = []
    branches.each do |b|
      branch = []
      predicateList.find_all_hash('branch_name', b).each do |n|
        branch << n['query']
      end
      branchQuery = '(' + branch.join(' AND ') + ')'
      queryBranches << branchQuery unless queryBranches.include?(branchQuery)
    end
    predicateQuery = queryBranches.join(' OR ')
    # pp predicateQuery
    predicateQuery
  end

  def self.get_predicateColumns(predicateList)
    columnList = []
    predicateList.each do |p|
      columnList += p['columns']
    end
    columnList.uniq
  end

  def self.column_str_constr(columnList)
    columnList.map(&:expr).join(',')
  end
end
