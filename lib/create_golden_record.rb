def createGR(golden_record_opr, script, tqueryObj)
  if golden_record_opr == 'c'
    create_golden_record(tqueryObj)
    puts 'Please verify golden record: verified (Y), not verified(N)'
    verified = STDIN.gets.chomp
    if verified == 'Y'
      DBConn.dump_golden_record(script)
    else
      abort('not verified')
    end
  elsif golden_record_opr == 'i'
    # import golden record
    query = 'drop table IF EXISTS golden_record;'
    DBConn.exec(query)
    # binding.pry
    DBConn.exec_golden_record_script(script)
    # abort('test')
  end
end

def create_golden_record(tQueryObj)
  new_target_list = tQueryObj.all_cols_select
  tQueryObj.predicate_tree_construct('t', true, 0)
  excluded_tbl = tQueryObj.create_excluded_tbl
  satisfied_tbl = tQueryObj.create_satisfied_tbl

  excluded_query =  "select #{new_target_list},'excluded'::varchar(30) as type, ''::varchar(30) as branch from #{excluded_tbl} limit 1"
  DBConn.tblCreation('golden_record', '', excluded_query)

  query = "select count(1) as cnt from golden_record where type = 'excluded'"
  res = DBConn.exec(query)
  # if no excluded rows are found, we generate an excluded row which contains all Null values
  if res[0]['cnt'].to_i == 0
    # binding.pry
    null_target_list = col_list.map do |col|
      "null as #{col.renamed_colname}"
    end.join(', ')
    null_target_list = " #{null_target_list} , 'excluded' as type, '' as branch"
    null_query = ReverseParseTree.reverseAndreplace(parseTree, null_target_list, '')
    null_query = "INSERT INTO golden_record #{null_query} limit 1"
    DBConn.exec(null_query)
    # binding.pry
  end

  satisfied_query = "SELECT distinct on (branch) #{new_target_list},'satisfied'::varchar(30) as type, branch from  #{satisfied_tbl}"
  satisfied_query = "INSERT INTO golden_record #{satisfied_query}"
  DBConn.exec(satisfied_query)
end


