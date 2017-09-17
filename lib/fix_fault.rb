def fix_join_type(joinErrList,fqueryObj,fix_rst_list)
    pp 'fixing join type error'
    pp 'join type error list'
    pp joinErrList
    startTime = Time.now
    psNew = AutoFix.JoinTypeFix(joinErrList, fqueryObj.parseTree)
    fQueryNew = ReverseParseTree.reverse(psNew)
    p 'New query after fixing join type error'
    p fQueryNew
    endTime = Time.now
    duration = (endTime - startTime).to_i
    fix_result = {}
    fix_result['test_type'] = 'jt'
    fix_result['query'] = fQueryNew
    fix_result['duration'] = duration
    fix_result['score'] = nil
    fix_rst_list << fix_result
    return QueryObj.new(query: fQueryNew, pkList: fqueryObj.pkList, table: 'f_result')
end

def fix_join_cond(new_join_key,old_join_key,fqueryObj,fix_rst_list)
  # pp new_from
  startTime = Time.now
  new_from,candidate_join_key = AutoFix.join_key_fix(new_join_key, fqueryObj)
  unless (candidate_join_key - old_join_key).empty?
    puts 'Fixing join key'
    old_from = fqueryObj.from_query
    fQueryNew = fqueryObj.query.gsub(old_from,new_from)
    # fQueryNew = AutoFix.fix_from_query(fqueryObj.query,new_from)
    p 'New query after fixing condition error'
    pp fQueryNew
    endTime = Time.now
    duration = (endTime - startTime).to_i
    fix_result = {}
    fix_result['test_type'] = 'jc'
    fix_result['query'] = fQueryNew
    fix_result['duration'] = duration
    fix_result['score'] = nil
    fix_rst_list << fix_result
    return QueryObj.new(query: fQueryNew, pkList: fqueryObj.pkList, table: 'f_result')
  else
    puts 'No Join Key Error'
    return fqueryObj 
  end

end

def fix_where_cond(tqueryObj,fqueryObj,test_result,dbname,script,idx,method,fix_rst_list)
    return if test_result.count == 0
    puts 'begin fix'
    startTime = Time.now
    excluded_tbl = tqueryObj.create_excluded_tbl
    satisfied_tbl = tqueryObj.create_satisfied_tbl

    current_query = fqueryObj.query
    current_score = fqueryObj.score['totalScore']
    current_queryObj = fqueryObj
    newlocalizeErr = nil

    faulty_script = "#{script}_#{idx.to_s}"

    # test_result = localizeErr.get_test_result
    iterate_cnt = 1
    test_result.each do |rst|
      next if rst.suspicious_score.to_i <= 0

      terminated = false
      puts "fixing node: #{rst.branch_name} #{rst.node_name} at location #{rst.location}"
      pp rst.columns
      mutation = Mutation.new(current_queryObj,excluded_tbl,satisfied_tbl,dbname,"#{faulty_script}_#{iterate_cnt}")
      is_ds = false
      neighborQueryObj = mutation.generate_neighbor_query(rst,is_ds)
      unless is_ds
        # localizeErr.selecionErr(method)
        begin
          Timeout.timeout(600) do
            newlocalizeErr = LozalizeError.new(neighborQueryObj, tqueryObj)
            newlocalizeErr.selecionErr(method)
          end
        rescue Timeout::Error
          puts 'fault localization can not complete in 600s and is terminated'
          terminated = true
        end

        unless terminated
          new_score = newlocalizeErr.getSuspiciouScore
          # if new_score['totalScore'] < best_score
          current_query = neighborQueryObj.query
          current_score = new_score['totalScore']
          current_queryObj = neighborQueryObj
        end
        if current_score ==0
          break
        end
      else
        break if iterate_cnt >= f_options[:relevent].count()
      end
      iterate_cnt = iterate_cnt + 1

    end
    endTime= Time.now
    duration = (endTime - startTime).to_i

    fix_result = {}
    fix_result['test_type'] = 'w'
    fix_result['query'] = current_query
    fix_result['duration'] = duration
    fix_result['score'] = current_score
    fix_rst_list << fix_result

    # update_fix_result_tbl(idx,'w',tqueryObj.query,current_query,fix_duration, current_score)
    return current_score
end