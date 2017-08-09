require_relative 'db_connection'
require_relative 'query_builder'
require 'fortune'
class Columns_Combination
  attr_reader :c_hash, :v_hash
  def initialize(columns)
    @table = 'processed_columns_combinations'

    pkList = 'ith_combination,int_presentation'
    @cnt = columns.count
    # @series_array = (0..@cnt-1).to_a
    # max = 2**@cnt-1
    # query = %Q(select 0::bit as processed,
    # length(replace(generate_series::bit(#{cnt})::varchar(30),'0',''))::int as ith_combination,
    # generate_series::bigint as int_presentation,
    # generate_series::bit(#{cnt}) as bit_combination
    # FROM generate_series(1,#{max});)
    # processed_columns_combinations
    query = %(select length(replace(0::bit(#{@cnt})::varchar(30),'0',''))::int as ith_combination,
    0::bigint as int_presentation
    FROM generate_series(1,1))
    # pp "begin cc: #{Time.now()}"
    DBConn.tblCreation(@table, pkList, query)

    # cc table
    cctbl = 'cc'
    query = %(select 0::int as ith_combination,
    0::bigint as int_presentation,
    0::bit(#{@cnt}) as bit_combination
    from processed_columns_combinations where 1=0)
    # pp query
    DBConn.tblCreation(cctbl, pkList, query)

    @c_hash = {}
    @v_hash = {}
    columns.each_with_index do |c, idx|
      @c_hash[c.hash] = idx
      @v_hash[idx] = c
    end
    @count_hash = {}
    (1..@cnt).to_a.each do |c|
      @count_hash[c] = Fortune::C.calc(elements: @cnt, select: c)
    end
    end

  def encode(column_set)
    val = 0
    column_set.each do |c|
      val += 2**@c_hash[c.hash]
    end
    val
    # val.to_s(2)
  end

  def decode(binary_string)
    reverse_string = binary_string.reverse
    positions = (0...reverse_string.length).find_all { |i| reverse_string[i] == '1' }
    # pp positions
    rst = []
    positions.each do |p|
      rst << @v_hash[p]
    end
    rst
  end

  def get_ith_combinations(i)
    # int_presentation_arry = @series_array.combination(i).to_a.map{|x| x.inject(0){ |product, n| product+ 2**n }}
    query = "SELECT bit_comb as bit_combination FROM get_combinations(#{@cnt},#{i}) ;"

    rst = DBConn.exec(query)
    col_combinations = []
    rst.each do |r|
      col_combinations << decode(r['bit_combination'])
    end
    col_combinations
  end

  def delete(column_set)
    int_presentation = encode(column_set)
    ith_combination = column_set.count
    bit_combination = int_presentation.to_s(2)
    query = %(insert into #{@table}
    select #{ith_combination} as ith_combination,
    #{int_presentation} as int_presentation
    where not exists
    (select ith_combination
    from #{@table}
    where ith_combination = #{ith_combination}
    and int_presentation = #{int_presentation}))
    # query = "update columns_combinations set processed = 1::bit where ith_combination = #{ith_combination} and int_presentation = #{int_presentation}"
    # pp query
    # pp column_set
    DBConn.exec(query)
    @count_hash[ith_combination] = @count_hash[ith_combination] - 1
    # pp "@count_hash[#{ith_combination}]: #{@count_hash[ith_combination]}"
  end

  def get_max_ith_combination
    # query = "select max(ith_combination) as max from #{@table}  where processed = 0::bit"
    # rst = DBConn.exec(query)
    # rst[0]['max'].to_i
    @count_hash.key(@count_hash.values.max)
  end

  def reset_processed
    query = "delete from #{@table}"
    # pp query
    DBConn.exec(query)

    (1..@cnt).to_a.each do |c|
      @count_hash[c] = Fortune::C.calc(elements: @cnt, select: c)
    end
  end
end
