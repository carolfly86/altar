require_relative 'integer_helper'
# require 'pry'
module Mann_whitney
  # attr_accessor :total_true, :total_false, :passed_true, :passed_false

  def Mann_whitney.ranking_score(total_true, total_false, passed_true, passed_false)
    total = total_false + total_true
    total_passed = passed_true+passed_false
    # k = self.num_of_combination(total,total_passed)

    max_false = [total_passed,total_false].min
    max_true = [total_passed,total_true].min
    puts "max_false: #{max_false}"
    puts "max_true: #{max_true}"

    return 0 if (passed_false == total_false) or (passed_true == total_true)
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