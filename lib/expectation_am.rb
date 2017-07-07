class Expectation_AM
  # def initialize(support,behavior)
  # end
  # attr_accessor :support, :behavior
  def initialize(support, behavior)
    @support = support
    @behavior = behavior
    query = "select * from t_result where #{behavior}"
    @bhPS = PgQuery.parse(query).parsetree[0]
    behaviorDomain
  end

  def behaviorDomain
    # query = "select * from t_result where #{@behavior}"
    # ps = PgQuery.parse(query).parsetree[0]
    whereClause = @bhPS['SELECT']['whereClause']
    aexpr = whereClause.keys[0]
    # get opr
    opr = case aexpr
          when 'AEXPR'
            whereClause[aexpr]['name'][0]
          when 'AEXPR AND'
            # if the behavior is BETWEEn
            'BETWEEN'
          when 'AEXPR IN'
            case whereClause[aexpr]['name'][0]
            when '='
              'IN'
            when '<>'
              'NOT IN'
            else
              ''
                  end
          # domain = whereClause["AEXPR IN"]["rexpr"].length
          else
            ''
          end
    # if operator is IN,  domain is length of array

    case opr
    # if operator is =, 'is',  domain is 1
    when '='
      @bhDomain = 1
      @bhCol = whereClause[aexpr]['lexpr']['COLUMNREF']['fields'][0]
    # if operator is IN,  domain is length of array
    when 'IN'
      @bhDomain = whereClause[aexpr]['rexpr'].length
      @bhCol = whereClause[aexpr]['lexpr']['COLUMNREF']['fields'][0]
    # if operator is BETWEEN,  domain right expr - left expr
    when 'BETWEEN'
      lexprConstant = whereClause[aexpr]['lexpr']['AEXPR']['rexpr']['A_CONST']['val']
      rexprConstant = whereClause[aexpr]['rexpr']['AEXPR']['rexpr']['A_CONST']['val']
      @bhDomain = (lexprConstant - rexprConstant).abs
      @bhCol = whereClause[aexpr]['lexpr']['AEXPR']['lexpr']['COLUMNREF']['fields'][0]
    # if operator is >, <, != , NOT IN,  domain is ....
    # get the column
    # find the column data type
    # only calculate integer type, for other types the domain is infinite
    else
      @bhCol = whereClause[aexpr]['lexpr']['COLUMNREF']['fields'][0]
      res = DBConn.getColByDataCategory('t_result', '', @bhCol)
      # binding.pry
      dataType = res[0]['data_type']
      typeCategory = res[0]['typcategory']
      if typeCategory == 'N'
        case dataType
        when 'year'
          @bhDomain = 2015 - 1900
        else # 'integer'
          query = "select max(#{@bhCol}) - min(#{@bhCol}) as domain from t_result;"
          res = DBConn.exec(query)
          @bhDomain = res[0]['domain']
        end
      else
        @bhDomain = 999_999
      end
    end
  end

  def separationScore
    query = "select (1-(select count(1) from film where #{@support} and #{@behavior})::float/(select count(1) as separation from film)::float)::float  as separation"
    res = DBConn.exec(query)
    res[0]['separation']
  end

  def supportScore(fDataset)
    query = "select count(1) as colNum from information_schema.columns where table_name = 'f_result';"
    res = DBConn.exec(query)
    colNum = res[0]['colnum']
    query = "select ( select count(1) from #{fDataset} where #{@support})::float /( (select count(1)* #{colNum} from #{fDataset})::float ) as support;  "
    res = DBConn.exec(query)
    res[0]['support']
  end

  def selectivityScore
    # bDomain = behaviorDomain()
    (1 / @bhDomain .to_f).to_f
    # query = "select ( 1 / ( select count(1) from #{tDataset} where #{})) as selectivity;  "
    # res = DBConn.exec(query)
    # res[0]['selectivity']
  end

  def significanceScore(tDataset)
    supportScore = supportScore(tDataset)
    selectivityScore = selectivityScore(tDataset)
    supportScore * selectivityScore
  end

  def satisfaction(fDataset)
    query = "select count(1) as count from #{fDataset} where #{@support}"
    res = DBConn.exec(query)
    d = res[0]['count'].to_i
    if d > 0
      query = "select ((select count(1) as count from #{fDataset} where #{@support} and #{@behavior})::float /(select count(1) as count from #{fDataset} where #{@support})::float)::float as satisfaction;"
      res = DBConn.exec(query)
      sfScore = res[0]['satisfaction']
    else
      sfScore = 0
    end
    sfScore
  end

  def updSatCvgMapTbl(fDataset, fPKList, satisfactionMapTbl)
    pkJoin = fPKList.split(',').map { |pk| "s.#{pk} = f.#{pk}" }.join(' AND ')
    # update coverageMapTbl

    query = "UPDATE #{satisfactionMapTbl} as s "\
            "SET #{@bhCol} = 1 "\
            "FROM #{fDataset} as f "\
            "WHERE #{pkJoin} "\
            "AND f.#{@support}; "
    p query
    res = DBConn.exec(query)

    # update satisfactionMapTbl
    query = "UPDATE #{satisfactionMapTbl} as s "\
            "SET #{@bhCol} = 2 "\
            "FROM #{fDataset} as f "\
            "WHERE #{pkJoin} "\
            "AND f.#{@support} and f.#{@behavior}; "
    p query
    res = DBConn.exec(query)
  end
end
