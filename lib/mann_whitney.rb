require_relative 'integer_helper'
# require 'pry'
module Mann_whitney
  # attr_accessor :total_true, :total_false, :passed_true, :passed_false

  def Mann_whitney.ranking_calculation
    query = "with true_stat as (select passed_cnt+failed_cnt as total_true, passed_cnt as passed_true, branch_name||'-'||node_name as bn_name   from tarantular_tbl where eval_result = 't'), 
false_stat as (select passed_cnt+failed_cnt as total_false, passed_cnt as passed_false, branch_name||'-'||node_name as bn_name  from tarantular_tbl where eval_result = 'f')
select t.bn_name, f.total_false, f.passed_false, t.total_true,t.passed_true from true_stat t
join false_stat f
on f.bn_name = t.bn_name ;
"
    puts query
    mw_set = DBConn.exec(query)
    mw_result = Hash.new()
    mw_set.each do |r|
      ms_score = Mann_whitney.ranking_score(r['total_true'].to_i, r['total_false'].to_i, r['passed_true'].to_i, r['passed_false'].to_i)
      # query = "update tarantular_result set mw_score = #{ms_score} where bn_name = '#{r['bn_name']}'"
      puts r['bn_name']
      puts ms_score
      mw_result[r['bn_name']] = ms_score
    end
    SFL_Ranking.ranking_update('mw',mw_result)
  end

  def Mann_whitney.ranking_score(total_true, total_false, passed_true, passed_false)
    total = total_false + total_true
    total_passed = passed_true+passed_false
    # k = self.num_of_combination(total,total_passed)

    max_false = [total_passed,total_false].min
    max_true = [total_passed,total_true].min
    puts "max_false: #{max_false}"
    puts "max_true: #{max_true}"

    return 0 if ((passed_false == total_false)\
              or (passed_true == total_true)\
              or (passed_false == 0 and total_false >0)\
              or (passed_true ==0 and total_true >0))
    # if passed_false < total_false
      k_l =  (Comb_Calculator.opt_sum_of_comnibations(total_false, passed_false+1, max_false)
        + Comb_Calculator.opt_sum_of_comnibations(total_true,0,total_passed - passed_false- 1)
        )
      k_h = ( Comb_Calculator.opt_sum_of_comnibations(total_false,0,passed_false-1)
        + Comb_Calculator.opt_sum_of_comnibations(total_true,total_passed - passed_false + 1,max_true)
        )

    return -([k_l,k_h].min)
  end
end