class Expectation
  # def initialize(support,behavior)
  # end
  attr_accessor :support, :behavior

  def behaviorDomain()
    query = "select * from t_result where #{@behavior}"
    ps = PgQuery.parse(query).parsetree[0]
    whereClause = ps['SELECT']["whereClause"]
    aexpr = whereClause.keys[0]
    # get opr
    case aexpr
    when "AEXPR"
      opr = whereClause[aexpr]["name"][0]
    when "AEXPR IN"
      case whereClause[aexpr]["name"][0]
      when "="
        opr = 'IN'
      when "<>"
        opr = 'NOT IN'
      else
        opr =''
      end
      # domain = whereClause["AEXPR IN"]["rexpr"].length
    else
      opr =''
    end
    # if operator is IN,  domain is length of array

    case opr
    # if operator is =, 'is',  domain is 1
    when '='
      domain = 1
    # if operator is IN,  domain is length of array
    when 'IN'
      domain = whereClause[aexpr]["rexpr"].length
    # if operator is >, <, != , NOT IN,  domain is ....
        # get the column
        # find the column data type 
        # only calculate integer type, for other types the domain is infinite
    else
      col = whereClause[aexpr]["lexpr"]["COLUMNREF"]["fields"][0]
      res = DBConn.getColByDataCategory('t_result','',col)
      dataType = res[0]["data_type"]
      typeCategory = res[0]["typcategory"]
      if typeCategory == 'N'
        case dataType
        when 'year'
          domain = 2015-1900
        else # 'integer'
          query = "select max(#{col}) - min(#{col}) as domain from t_result;"
          res = DBConn.exec(query)
          domain = res[0]['domain']
        end
      else
        domain = 999999
      end
    end
    
    domain

 
  end

  def separationScore()
    query = "select count(1) as separation from film where #{support} and #{behavior}"
    res = DBConn.exec(query)
    res[0]['separation']
  end
  def supportScore(tDataset)
      query = "select count(1) as colNum from information_schema.columns where table_name = 't_result';"
      res = DBConn.exec(query)
      colNum = res[0]['colnum']
      query = "select ( select count(1) from #{tDataset} where #{@support})::float /( (select count(1)* #{colNum} from #{tDataset})::float ) as support;  "
      p query
      res = DBConn.exec(query)
      res[0]['support'] 	
  end
  def selectivityScore()
      bDomain = behaviorDomain()
      (1/bDomain.to_f).to_f
      # query = "select ( 1 / ( select count(1) from #{tDataset} where #{})) as selectivity;  "
      # res = DBConn.exec(query)
      # res[0]['selectivity']

  end
  def significanceScore(tDataset)
    supportScore = supportScore(tDataset)
    selectivityScore= selectivityScore(tDataset)
    supportScore*selectivityScore
  end
  def satisfaction(tDataset,fDataset)
    # satisfaction should be |t-f|/t
      query = "select count(1) as count from #{tDataset} where #{@support} and #{@behavior};"
      res = DBConn.exec(query)
      tCount = res[0]['count']

      query = "select count(1) as count from #{fDataset} where #{@support} and #{@behavior};"
      res = DBConn.exec(query)
      fCount = res[0]['count']
      # puts fCount.to_f
      # # puts (tCount.to_f-fCount.to_f).abs
      # puts tCount.to_f
      r = [tCount, fCount]
      # r = 1.to_f-((tCount.to_f-fCount.to_f).abs/tCount.to_f)

  end
end
