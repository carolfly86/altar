require 'pg_query'

class Tarantular
  # attr_accessor :fPS
  # def initialize(fQuery, tQuery, parseTree)
  attr_reader :total_test_cnt, :ranks
  def initialize(fQueryObj, tQueryObj, test_id, is_join = false)
    # @fQuery=fqueryObj['query']
    # @tQuery=tqueryObj['query']

    @fQueryObj = fQueryObj
    @tQueryObj = tQueryObj
    @test_id = test_id

    # @fTable = fQueryObj.table
    # @tTable = tQueryObj.table
    @fTable = Table.new(fQueryObj.table)
    @tTable = Table.new(tQueryObj.table)

    @fPS = fQueryObj.parseTree
    @tPS = tQueryObj.parseTree

    # @pkListQuery = tQueryObj.pkList
    # res = DBConn.exec(@pkListQuery)
    @pkList = tQueryObj.pkList.split(',').map{|c| c.strip}
    # res.each do |r|
    #   @pkList << r['attname']
    # end
    # @pkJoin = ''
    # pkSelectArry = []
    # pkJoinArry = []
    # @pkList.each do |c|
    #   # pkJoinArry.push("COALESCE(t.#{c},0) = COALESCE(f.#{c},0)")
    #   pkSelectArry.push("f.#{c}")
    # end
    # pp @pkList
    # @pkSelect = pkSelectArry.join(',')
    # @pkJoin = pkJoinArry.join(' AND ')

    if is_join
      # if PUT is JOIN clause, we construct a fake wherePT from JOIN conditions
      f_join_key_list = JoinKeyIdent.new(@fQueryObj).extract_from_parse_tree
      @f_join_cond = f_join_key_list.map{|keys| keys.to_a.map{|c| c.select_name}.join(' = ')}.join(' AND ')
      fake_query = "select * from t where #{@f_join_cond}"
      @wherePT = PgQuery.parse(fake_query).parsetree[0]['SELECT']['whereClause']
      # @whereStr = join_cond

      t_join_key_list = JoinKeyIdent.new(@tQueryObj).extract_from_parse_tree
      @t_join_cond = t_join_key_list.map{|keys| keys.to_a.map{|c| c.select_name}.join(' = ')}.join(' AND ')

    else
      @wherePT = @fPS['SELECT']['whereClause']
      # @whereStr = ReverseParseTree.whereClauseConst(@wherePT)
    end
    @fromPT =  @fPS['SELECT']['fromClause']
    # generate predicate tree from where clause
    root = Tree::TreeNode.new('root', '')
    @predicateTree = PredicateTree.new('f', 't', @test_id)
    # pp @wherePT
    @predicateTree.build_full_pdtree(@fromPT[0], @wherePT, root)
    # @pdtree = @predicateTree.pdtree
    # @pdtree.print_tree
    # pp 'branches'
    # pp @predicateTree.branches
    # @fromCondStr = ReverseParseTree.fromClauseConstr(@fromPT)
    @tarantular_tbl = 'tarantular_tbl'

    create_tarantular_tbl
    # create_t_f_union_table
    create_execution_trace(is_join)
  end

  def predicateTest
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
    # pk_selectquery =  ReverseParseTree.reverseAndreplace(@fPS, '', '#NODEQUERY#')
    # pk_selectquery = "with t as ( #{pk_selectquery} )"

    # selectQuery = pk_selectquery +
    #               " SELECT COUNT(1) as cnt, type  FROM tarantular_execution f JOIN t on #{@pkJoin} group by type"
    @predicateTree.branches.each do |branch|
      branch.nodes.each do |node|
        if node.columns.count >1
          node_query = node.columns.map{|c| c.renamed_colname}.join(' = ')
        else
          c = node.columns[0]
          node_query = node_query.gsub(c.select_name, c.renamed_colname)
        end

        selectQuery = "SELECT COUNT(1) as cnt, type  FROM tarantular_execution WHERE #{node_query} group by type"
        res = DBConn.exec(selectQuery)
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

        set_query = "failed_cnt = #{t_failed_cnt}, passed_cnt = #{t_passed_cnt}, total_failed_cnt = #{total_failed_cnt}, total_passed_cnt = #{total_passed_cnt}"
        eval_result = "eval_result = 't'"
        query = upd_query.gsub('#SETQUERY#', set_query).gsub('#EVAL#', eval_result)
        # puts query
        DBConn.exec(query)

        f_failed_cnt = total_failed_cnt - t_failed_cnt
        f_passed_cnt = total_passed_cnt - t_passed_cnt
        set_query = "failed_cnt = #{f_failed_cnt}, passed_cnt = #{f_passed_cnt}, total_failed_cnt = #{total_failed_cnt}, total_passed_cnt = #{total_passed_cnt}"
        eval_result = "eval_result = 'f'"
        query = upd_query.gsub('#SETQUERY#', set_query).gsub('#EVAL#', eval_result)
        # puts query
        DBConn.exec(query)
      end
    end

    # tarantular score
    query = "update #{@tarantular_tbl} set tarantular_score = case when failed_cnt + passed_cnt = 0 or total_failed_cnt = 0 then 0 "\
            'else (failed_cnt::float(2)/total_failed_cnt::float(2))/(failed_cnt::float(2)/total_failed_cnt::float(2) + passed_cnt::float(2)/total_passed_cnt::float(2)) end '\
            ', ochihai_score = case when failed_cnt + passed_cnt = 0 or total_failed_cnt = 0 then 0 '\
            'else failed_cnt::float(2)/(|/(total_failed_cnt*(failed_cnt + passed_cnt)::bigint))::float(2) end ' +
            # ", naish2_score = case when failed_cnt = 0 then 0 else failed_cnt::float(2) - passed_cnt::float(2)/(total_passed_cnt+1)::float(2) end"+
            ', naish2_score = failed_cnt::float(2) - passed_cnt::float(2)/(total_passed_cnt+1)::float(2) '\
            ', kulczynski2_score = case when failed_cnt + passed_cnt = 0 or total_failed_cnt = 0 then 0 else '\
            '  (failed_cnt::float(2)/total_failed_cnt::float(2) + failed_cnt::float(2)/(failed_cnt + passed_cnt)::float(2))/2 end ' \
            # ", kulczynski2_score = (failed_cnt::float(2)/total_failed_cnt::float(2) + failed_cnt::float(2)/(failed_cnt + passed_cnt)::float(2))/2 "+
            ', wong1_score = failed_cnt '

    puts query
    DBConn.exec(query)

    # rank tarantular score
    query = "INSERT INTO tarantular_result SELECT test_id,  branch_name||'-'||node_name,"\
            ' sum(tarantular_score) as tarantular_score, rank() over(order by sum(tarantular_score) desc) AS tarantular_rank , '\
            ' sum(ochihai_score) as ochihai_score, rank() over(order by sum(ochihai_score) desc) AS ochihai_rank'\
            ', sum(naish2_score) as sum_naish2_score, rank() over(order by sum(naish2_score) desc) AS naish2_score'\
            ', sum(kulczynski2_score) as kulczynski2_score, rank() over(order by sum(kulczynski2_score) desc) AS kulczynski2_score'\
            ', sum(wong1_score) as sum_wong1_score, rank() over(order by sum(wong1_score) desc) AS wong1_score'\
            ' from tarantular_tbl group by branch_name,node_name, test_id;'
    # puts query
    DBConn.exec(query)

    # statistical score
    query = "with stats as ( select branch_name||'-'||node_name as bn_name
    ,sober_score(passed_cnt::numeric, total_passed_cnt::numeric,failed_cnt::numeric, total_failed_cnt::numeric) as sober_score
    ,liblit_score(passed_cnt::numeric, total_passed_cnt::numeric,failed_cnt::numeric, total_failed_cnt::numeric) as liblit_score
    from tarantular_tbl where eval_result = 't')
    update tarantular_result as ts "\
            ' SET sober_score = s.sober_score, '\
            ' liblit_score = s.liblit_score '\
            ' FROM stats s '\
            ' where s.bn_name = ts.bn_name'

    puts query
    DBConn.exec(query)

    # Mann whitney ranking
    Mann_whitney.ranking_calculation

    # crosstab ranking
    Crosstab.ranking_calculation

    query = " with rank as (select bn_name, rank() over(order by sober_score desc) as sober_rank,
 rank() over(order by liblit_score desc) as liblit_rank
 from tarantular_result
 )
  update tarantular_result as ts
  SET sober_rank = r.sober_rank,
   liblit_rank = r.liblit_rank
   FROM rank r  where r.bn_name = ts.bn_name;"
    # puts query
    DBConn.exec(query)

    %w(tarantular ochihai kulczynski2 sober liblit naish2).each do |name|
      SFL_Ranking.tie_check(name)
    end
  end
  # end

  def harmonic_mean(rank)
    return 0 if rank.to_i == 0

    2 / (rank.to_f + 1)
  end

  def relevence(relevent_set)
    relevent_bn = relevent_set.map { |r| "'#{r}'" }.join(',')
    query = "select tarantular_rank,ochihai_rank,naish2_rank,kulczynski2_rank,wong1_rank,sober_rank,liblit_rank,mw_rank,crosstab_rank from tarantular_result where bn_name in (#{relevent_bn})"
    # puts query
    res = DBConn.exec(query)
    @ranks = {}
    tlist = []
    olist = []
    nlist = []
    klist = []
    slist = []
    llist = []
    wlist = []
    mwlist = []
    cbtlist = []

    t_hm = 0
    o_hm = 0
    n_hm = 0
    k_hm = 0
    s_hm = 0
    l_hm = 0
    mw_hm = 0
    cbt_hm = 0

    if res.count > 0
      res.each do |r|
        tlist << r['tarantular_rank'].to_s
        t_hm += harmonic_mean(r['tarantular_rank'])
        olist << r['ochihai_rank'].to_s
        o_hm += harmonic_mean(r['ochihai_rank'])
        nlist << r['naish2_rank'].to_s
        n_hm += harmonic_mean(r['naish2_rank'])
        klist << r['kulczynski2_rank'].to_s
        k_hm += harmonic_mean(r['kulczynski2_rank'])
        slist << r['sober_rank'].to_s
        s_hm += harmonic_mean(r['sober_rank'])
        llist << r['liblit_rank'].to_s
        l_hm += harmonic_mean(r['liblit_rank'])
        wlist << r['wong1_rank'].to_s

        mwlist << r['mw_rank'].to_s
        mw_hm += harmonic_mean(r['mw_rank'])

        cbtlist << r['crosstab_rank'].to_s
        cbt_hm += harmonic_mean(r['crosstab_rank'])
      end
      t_hm /= relevent_set.count
      o_hm /= relevent_set.count
      n_hm /= relevent_set.count
      k_hm /= relevent_set.count
      s_hm /= relevent_set.count
      l_hm /= relevent_set.count
      mw_hm /= relevent_set.count
      cbt_hm /= relevent_set.count

      @ranks['tarantular_rank'] = tlist.join(',')
      @ranks['ochihai_rank'] = olist.join(',')
      @ranks['naish2_rank'] = nlist.join(',')
      @ranks['kulczynski2_rank'] = klist.join(',')
      @ranks['wong1_rank'] = wlist.join(',')
      @ranks['sober_rank'] = slist.join(',')
      @ranks['liblit_rank'] = llist.join(',')
      @ranks['mw_rank'] = mwlist.join(',')
      @ranks['crosstab_rank'] = cbtlist.join(',')

      @ranks['tarantular_hm'] = t_hm
      @ranks['ochihai_hm'] = o_hm
      @ranks['naish2_hm'] = n_hm
      @ranks['kulczynski2_hm'] = k_hm
      @ranks['wong1_hm'] = 0
      @ranks['sober_hm'] = s_hm
      @ranks['liblit_hm'] = l_hm
      @ranks['mw_hm'] = mw_hm
      @ranks['crosstab_hm'] = cbt_hm
    else
      @ranks = { 'tarantular_rank' => '0', 'ochihai_rank' => '0', 'naish2_rank' => '0', 'kulczynski2_rank' => '0',
                 'wong1_rank' => '0', 'sober_rank' => '0', 'liblit_rank' => '0', 'mw_rank' => '0', 'crosstab_rank' => '0',
                 'tarantular_hm' => '0', 'ochihai_hm' => '0', 'naish2_hm' => '0', 'kulczynski2_hm' => '0',
                 'wong1_hm' => '0', 'sober_hm' => '0', 'liblit_hm' => '0', 'mw_hm' => '0', 'crosstab_hm' => '0' }
    end
    @ranks
  end

  def failed_tuple_count
    query = "select count(1) as failed_cnt from tarantular_execution where type = 'f'"
    res = DBConn.exec(query)
    res[0]['failed_cnt']
  end

  private

  def create_tarantular_tbl
    query = "select #{@test_id} as test_id, branch_name, node_name, query,location, "\
            " 't'::boolean as eval_result, 0 as passed_cnt, 0 as total_passed_cnt, "\
            ' 0 as failed_cnt, 0 as total_failed_cnt, 0::float(2) as tarantular_score, 0::float(2) as ochihai_score '\
            ' , 0::float(2) as naish2_score, 0::float(2) as kulczynski2_score , 0::float(2) as wong1_score '\
            ' from node_query_mapping'
    pkList = 'test_id, branch_name, node_name,eval_result'
    # puts query
    insert_query = "INSERT INTO #{@tarantular_tbl} " + query.gsub("'t'::boolean", "'f'::boolean")
    query = QueryBuilder.create_tbl(@tarantular_tbl, pkList, query)
    DBConn.exec(query)

    # puts insert_query
    DBConn.exec(insert_query)

    # create node based tarantular_tbl
    query =  %(DROP TABLE if exists tarantular_result;
CREATE TABLE tarantular_result
(test_id int, bn_name varchar(90)
,tarantular_score float(2),tarantular_rank int
,ochihai_score float(2), ochihai_rank int
,naish2_score float(2),naish2_rank int
,kulczynski2_score float(2), kulczynski2_rank int
,wong1_score float(2), wong1_rank int
,sober_score numeric null , sober_rank int null
,liblit_score numeric null, liblit_rank int null
, mw_rank int null
, crosstab_rank int null);)
    DBConn.exec(query)
  end

  def create_execution_trace(is_join)
    global_tbl_name = create_global_tbl
    global_tbl = Table.new(global_tbl_name)
    pklist = global_tbl.pk_column_list
    pkjoin = pklist.map{|c| "(t.#{c.colname} = g.#{c.colname} or (t.#{c.colname} is null and g.#{c.colname} is null))"}.join (' AND ')
    pkselect = pklist.map{|c| c.colname }.join (', ')
    # pkselect = @pkSelect.gsub('f.', '')

    included_select_query = "select t.*, 'p'::varchar(1) as type from #{@t_full_tbl} t join #{global_tbl_name} g on #{pkjoin} where g.type = 'p'"
    missing_select_query = "select t.*, 'f'::varchar(1) as type from #{@t_full_tbl} t join #{global_tbl_name} g on #{pkjoin} where g.type = 'f'"
    unwanted_select_query = "select t.*, 'f'::varchar(1) as type from #{@f_full_tbl} t join #{global_tbl_name} g on #{pkjoin} where g.type = 'f'"

    # pk_selectquery = "SELECT #{pkselect} from (SELECT * from #{@fromCondStr}) as tmp"
    select_query = "select * from ((#{included_select_query}) UNION ALL "\
                    "(#{unwanted_select_query}) UNION ALL "\
                    "(#{missing_select_query})) as tmp"

    QueryBuilder.exec_create_tbl('tarantular_execution', pkselect , select_query)


    # if is join query, add 1000 excluded rows from cross join
    if is_join
      join_excluded_tbl = @tQueryObj.create_join_excluded_tbl
      pkjoin = pklist.map{|c| "excld.#{c.colname} = te.#{c.colname}"}.join (' AND ')

      excluded_query = "insert into tarantular_execution "\
                       "select *, 'p' from #{join_excluded_tbl} excld "\
                       "where not exists (select 1 from tarantular_execution te where #{pkjoin}) limit 100"
      puts excluded_query
      DBConn.exec(excluded_query)

      # binding.pry
      # target_list =  ReverseParseTree.get_targetList(@fPS)
      # all_query = ReverseParseTree.convert_to_cross_join(@fPS, "#{target_list}, 'p'::varchar(1) as type")
    end
    # query = QueryBuilder.create_tbl('tarantular_execution', pkList, pk_selectquery)
    # puts query
    # DBConn.exec(query)

#     t_pkselect = @pkSelect.gsub('f.', 't.')
#     te_pkjoin = @pkJoin.gsub('f.', 'tc.').gsub('t.', 'te.')
#     query = "with tc as (
#     select case count(1) when 1 then 'f' else 'p' end as type,
#       #{t_pkselect}
# from tarantular_execution t
# join t_f_union f on #{@pkJoin}
# group by #{t_pkselect})
# update tarantular_execution te
# set type = tc.type
# from tc
# where #{te_pkjoin} "
#     pp query
#     DBConn.exec(query)
  end

  # global table contains included, missing, unwanted rows
  # for where predicate it also contains excluded rows

  def create_global_tbl
    # full table contains all columns without where predicate
    # so for where predicate it also contains excluded rows
    @t_full_tbl = @tQueryObj.create_full_rst_tbl
    @f_full_tbl = @fQueryObj.create_full_rst_tbl
    tbl = Table.new(@t_full_tbl)
    global_name = 'tf_global'
    pkList = tbl.pk_column_list.map{|c| c.colname}.join(', ')
    insert_query = "select #{pkList}, case count(1) when 1 then 'f' else 'p' end as type "\
                  "from (select #{pkList} from #{@t_full_tbl} UNION ALL "\
                  "select #{pkList} from #{@f_full_tbl}) as tmp "\
                  "group by #{pkList}"
    puts insert_query
    QueryBuilder.exec_create_tbl(global_name, pkList, insert_query)
    return global_name
  end
  # def create_t_f_union_table
  #   pkselect = @pkSelect.gsub('f.', '')
  #   query = "select #{pkselect},'t'::boolean as type from #{@tTable} UNION "\
  #           "select #{pkselect},'f'::boolean as type from #{@fTable}"
  #   pkList = @pkList.join(',') + ', type'
  #   # create_query = QueryBuilder.create_tbl('t_f_union', pkList, query)
  #   # begin 
  #   #   DBConn.exec(create_query)
  #   # rescue PG::NotNullViolation => e
  #   #   create_query = QueryBuilder.create_tbl_uix('t_f_union', pkList, query)
  #   #   puts create_query
  #   #   DBConn.exec(create_query)
  #   # end
  #   binding.pry
  #   QueryBuilder.exec_create_tbl('t_f_union', pkList, query)
  #   # query = "INSERT INTO t_f_union select #{pkselect},'f'::boolean as type from #{@fTable}"
  #   # # puts query
  #   # DBConn.exec(query)
  # end

  # def is_passed?(pkcond)
  #   query = "select count(1) as cnt from t_f_union where #{pkcond}"
  #   # puts query
  #   res = DBConn.exec(query)
  #   if res[0]['cnt'].to_i == 1
  #     return false
  #   else
  #     return true
  #   end
  # end
end
