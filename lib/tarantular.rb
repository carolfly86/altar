class Tarantular
  # attr_accessor :fPS
  #def initialize(fQuery, tQuery, parseTree)
  attr_reader :total_test_cnt, :ranks
  def initialize(fQueryObj,tQueryObj,test_id)
    # @fQuery=fqueryObj['query']
    # @tQuery=tqueryObj['query']

    @fQueryObj = fQueryObj
    @tQueryObj = tQueryObj
    @test_id = test_id

    @fTable = fQueryObj.table
    @tTable =  tQueryObj.table

    @fPS = fQueryObj.parseTree
    @tPS=tQueryObj.parseTree

    @pkListQuery = QueryBuilder.find_pk_cols(@tTable)
    res = DBConn.exec(@pkListQuery)
    @pkList = []
    res.each do |r|
      @pkList << r['attname']
    end
    @pkJoin = ''
    pkSelectArry =[]
    pkJoinArry = []
    @pkList.each do |c|
      pkJoinArry.push("t.#{c} = f.#{c}")
      pkSelectArry.push("f.#{c}" )
    end
    #pp @pkList
    @pkSelect = pkSelectArry.join(',')
    @pkJoin = pkJoinArry.join(' AND ')

    @wherePT = @fPS['SELECT']['whereClause']
    @fromPT =  @fPS['SELECT']['fromClause']
    # generate predicate tree from where clause
    root =Tree::TreeNode.new('root', '')
    @predicateTree = PredicateTree.new('f','t', @test_id)
    # pp @wherePT
    @predicateTree.build_full_pdtree(@fromPT[0], @wherePT,root)
    @pdtree = @predicateTree.pdtree
    @pdtree.print_tree
    # pp 'branches'
    # pp @predicateTree.branches
    @fromCondStr = ReverseParseTree.fromClauseConstr(@fromPT)
    @whereStr = ReverseParseTree.whereClauseConst(@wherePT)
    @tarantular_tbl = 'tarantular_tbl'

    create_tarantular_tbl()
    create_t_f_union_table()
    create_execution_trace()
  end




  def predicateTest()
    return if @wherePT.nil?
    # whereCondArry = ReverseParseTree.whereCondSplit(@wherePT)
    selectQuery = 'SELECT COUNT(1) as cnt , type  FROM tarantular_execution group by type'
    # puts pk_selectquery
    # targetList= @fPS['SELECT']['targetList']
    total_failed_cnt = 0
    total_passed_cnt = 0
    res = DBConn.exec(selectQuery)
    # pp res
    res.each do |r|
      # pp r
      if r['type'] == 'f'
        total_failed_cnt = r['cnt'].to_i
      else
        total_passed_cnt = r['cnt'].to_i
      end
    end
    @total_test_cnt = total_failed_cnt + total_passed_cnt


    # pk =@pkSelect.gsub('f.','')

    # pk_selectquery = "SELECT #{pkselect} from (SELECT * from #{@fromCondStr}) as tmp"
    pk_selectquery =  ReverseParseTree.reverseAndreplace(@fPS,'','#NODEQUERY#')
    pk_selectquery = "with t as ( #{pk_selectquery} )"

    selectQuery = pk_selectquery +
                  " SELECT COUNT(1) as cnt, type  FROM tarantular_execution f JOIN t on #{@pkJoin} group by type"
      @predicateTree.branches.each do |branch|

        branch.nodes.each do |node|
          nodeQuery_new = selectQuery.gsub('#NODEQUERY#',node.query)
          # 'select count(1), type from tarantular_execution join ' +' WHERE ' + node.query + ' GROUP BY type'
          # puts nodeQuery_new
          res = DBConn.exec(nodeQuery_new)
          t_failed_cnt = 0
          t_passed_cnt = 0
          res.each do |r|
            if r['type'] == 'f'
              t_failed_cnt = r['cnt'].to_i
            else
              t_passed_cnt = r['cnt'].to_i
            end
          end


          upd_query = "update #{@tarantular_tbl} set #SETQUERY# where #EVAL# and test_id = #{@test_id} and branch_name = '#{branch.name}' and node_name = '#{node.name}'"

          set_query ="failed_cnt = #{t_failed_cnt}, passed_cnt = #{t_passed_cnt}, total_failed_cnt = #{total_failed_cnt}, total_passed_cnt = #{total_passed_cnt}"
          eval_result = "eval_result = 't'"
          query = upd_query.gsub('#SETQUERY#', set_query).gsub('#EVAL#', eval_result)
          # puts query
          DBConn.exec(query)

          f_failed_cnt = total_failed_cnt - t_failed_cnt
          f_passed_cnt = total_passed_cnt - t_passed_cnt
          set_query ="failed_cnt = #{f_failed_cnt}, passed_cnt = #{f_passed_cnt}, total_failed_cnt = #{total_failed_cnt}, total_passed_cnt = #{total_passed_cnt}"
          eval_result = "eval_result = 'f'"
          query = upd_query.gsub('#SETQUERY#', set_query).gsub('#EVAL#', eval_result)
          # puts query
          DBConn.exec(query)
        end
      end
    # update tarantular_score
    # pkjoin = "t.branch_name = f.branch_name and t.node_name = f.node_name and t.test_id = f.test_id"
    # query = "update #{@tarantular_tbl} t set total_passed_cnt = f.total_passed_cnt, total_failed_cnt = f.total_failed_cnt "+
    #         "FROM
    #         (
    #             SELECT sum(passed_cnt) AS total_passed_cnt,
    #             sum(failed_cnt) AS total_failed_cnt,
    #             branch_name,node_name, test_id
    #             FROM #{@tarantular_tbl}
    #             group by branch_name,node_name,test_id
    #         ) as f
    #         where #{pkjoin}"
    # # puts query
    # DBConn.exec(query)

    # tarantular score
    query = "update #{@tarantular_tbl} set tarantular_score = case when failed_cnt = 0 and passed_cnt = 0 then 0 "+
    "else (failed_cnt::float(2)/total_failed_cnt::float(2))/(failed_cnt::float(2)/total_failed_cnt::float(2) + passed_cnt::float(2)/total_passed_cnt::float(2)) end "+
    ", ochihai_score = case when failed_cnt + passed_cnt = 0 then 0 "+
    "else failed_cnt::float(2)/(|/(total_failed_cnt*(failed_cnt + passed_cnt)::bigint))::float(2) end "
    # puts query
    DBConn.exec(query)

  # rank tarantular score
   query = "INSERT INTO tarantular_result SELECT test_id,  branch_name||'-'||node_name,"+
   " sum(tarantular_score) as sum_tarantular_score, rank() over(order by sum(tarantular_score) desc) AS tarantular_rank , "+
   " sum(ochihai_score) as sum_ochihai_score, rank() over(order by sum(ochihai_score) desc) AS ochihai_rank"+
   " from tarantular_tbl group by branch_name,node_name, test_id;"
    # puts query
    DBConn.exec(query)
  end
  # end

  def relevence(relevent_set)
    relevent_bn = relevent_set.map{|r| "'#{r}'"}.join(',')
    query = "select tarantular_rank,ochihai_rank from tarantular_result where bn_name in (#{relevent_bn})"
    # puts query
    res = DBConn.exec(query)
    @ranks={}
    tlist = []
    olist =[]
    if res.count>0
      res.each do |r|
        tlist<< r['tarantular_rank'].to_s
        olist<<r['ochihai_rank'].to_s
      end
      @ranks['tarantular_rank'] = tlist.join(',')
      @ranks['ochihai_rank'] = olist.join(',')
    else
      @ranks = {'tarantular_rank'=>'0', 'ochihai_rank'=>'0' }
    end
    @ranks
  end

  private
  def create_tarantular_tbl
    query = "select #{@test_id} as test_id, branch_name, node_name, query,location, "+
    " 't'::boolean as eval_result, 0 as passed_cnt, 0 as total_passed_cnt, "+
    " 0 as failed_cnt, 0 as total_failed_cnt, 0::float(2) as tarantular_score, 0::float(2) as ochihai_score "+
    " from node_query_mapping"
    pkList = 'test_id, branch_name, node_name,eval_result'
    # puts query
    insert_query = "INSERT INTO #{@tarantular_tbl} " +query.gsub("'t'::boolean","'f'::boolean")

    query=QueryBuilder.create_tbl(@tarantular_tbl,pkList,query)
    # puts query
    DBConn.exec(query)

    # puts insert_query
    DBConn.exec(insert_query)

    # create node based tarantular_tbl
      query =  %Q(DROP TABLE if exists tarantular_result;
  CREATE TABLE tarantular_result
  (test_id int, bn_name varchar(90), sum_tarantular_score float(2), tarantular_rank int, sum_ochihai_score float(2), ochihai_rank int);)
    DBConn.exec(query)

  end
  def create_execution_trace()
    pkselect =@pkSelect.gsub('f.','')

    # pk_selectquery = "SELECT #{pkselect} from (SELECT * from #{@fromCondStr}) as tmp"
    pk_selectquery =  ReverseParseTree.reverseAndreplace(@fPS,'','1=1')
    pk_selectquery = "select #{pkselect}, 'p'::varchar(1) as type from (#{pk_selectquery}) as tmp"
    pkList =  pkselect

    query=QueryBuilder.create_tbl('tarantular_execution',pkList,pk_selectquery)
    # puts query
    DBConn.exec(query)

    t_pkselect = @pkSelect.gsub('f.','t.')
    te_pkjoin = @pkJoin.gsub('f.','tc.').gsub('t.','te.')
    query = "with tc as (
    select case count(1) when 1 then 'f' else 'p' end as type,
      #{t_pkselect} 
from tarantular_execution t 
join t_f_union f on #{@pkJoin} 
group by #{t_pkselect}) 
update tarantular_execution te
set type = tc.type
from tc
where #{te_pkjoin} "
    # pp query
    DBConn.exec(query)
  end

  def create_t_f_union_table()
    pkselect =@pkSelect.gsub('f.','')
    query = "select #{pkselect},'t'::boolean as type from #{@tTable}"
    pkList = @pkList.join(',') +', type'
    query =QueryBuilder.create_tbl('t_f_union',pkList,query)
    # puts'create t_f_union'
    # puts query
    # create
    DBConn.exec(query)

    query = "INSERT INTO t_f_union select #{pkselect},'f'::boolean as type from #{@fTable}"
    # puts query
    DBConn.exec(query)
  end

  def is_passed?(pkcond)
    query = "select count(1) as cnt from t_f_union where #{pkcond}"
    # puts query
    res= DBConn.exec(query)
    if res[0]['cnt'].to_i == 1
      return false
    else
      return true
    end
  end


end