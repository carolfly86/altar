class Column_In_Branch
  attr_reader :cols_in_branch, :branch_num
  def initialize(branch_num)
    @branch_num = branch_num
    @cols_in_branch = Array.new(@branch_num) {Array.new}
  end
  def populate_cols_in_branch(mutation_tuples)
    mutation_tuples.each do |ex|
      cols = ex['mutation_cols'].split(',')
      idx_arry =  [*0..@branch_num-1]
      cols.each do |col|
        branch_contain_col = @cols_in_branch.find{|col_arry| col_arry.include?(col)}
        if branch_contain_col.nil?
          idx = idx_arry[0]
          @cols_in_branch[idx]<< col
          idx_arry.delete(idx)
        else
          idx_arry.delete(idx)
        end
      end
    end
  end
end
