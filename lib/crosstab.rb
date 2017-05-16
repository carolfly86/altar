module Crosstab
  # attr_accessor :total_true, :total_false, :passed_true, :passed_false
  def Crosstab.ranking_calculation

      query = "select passed_cnt,failed_cnt,
        total_passed_cnt,total_failed_cnt,
         branch_name||'-'||node_name as bn_name,
         eval_result
        from tarantular_tbl"
       rst = DBConn.exec(query)
       result = Hash.new()
        rst.each do |r|
          puts "bn_name: #{r['bn_name']}"
          puts "eval: #{r['eval_result']}"
          result[r['bn_name']] = 0 if result[r['bn_name']].nil?
          score = Crosstab.ranking_score(r['passed_cnt'].to_f, r['failed_cnt'].to_f, r['total_passed_cnt'].to_f, r['total_failed_cnt'].to_f)
          # query = "update tarantular_result set mw_score = #{ms_score} where bn_name = '#{r['bn_name']}'"
          puts score
          result[r['bn_name']] = result[r['bn_name']] + score
          puts result[r['bn_name']]
        end

      SFL_Ranking.ranking_update('crosstab',result)
  end
  def Crosstab.ranking_score(passed_cnt, failed_cnt, total_passed_cnt, total_failed_cnt)
    n_s = total_passed_cnt.to_f
    n_f = total_failed_cnt.to_f
    n_cf = failed_cnt.to_f
    n_cs = passed_cnt.to_f


    n = n_s + n_f
    n_c = n_cs+n_cf
    n_u = n-n_c
    n_uf = n_f- n_cf
    n_us = n_s - n_cs

    return 1 if n_s == 0
    return -1 if n_f == 0 or n_c == 0
    return 0 if n_f == n_cf or n_s == n_cs

    binding.pry if n_f ==0 or\
                  n_s ==0 or\
                  n_u ==0 or\
                  n_c ==0

    e_cf = (n_c*n_f)/n
    e_cs = (n_c*n_s)/n
    e_uf = (n_u*n_f)/n
    e_us = (n_u*n_s)/n


    chi_square = (n_cf-e_cf)**2/e_cf +\
                  (n_cs-e_cs)**2/e_cs +\
                  (n_uf-e_uf)**2/e_uf +\
                  (n_us-e_us)**2/e_us
    contig_coef = (chi_square/n)
    p_f = n_cf/n_f
    p_s = n_cs/n_s
    p = p_f/p_s
    puts "chi_square : #{chi_square}"
    # puts p
    susp_score = case  when p ==1 then 0
                        when p>1 then contig_coef
                        else -contig_coef
                        end

    return susp_score
  end
end