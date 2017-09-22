require 'decisiontree'
require_relative 'db_connection'

class DecisionTreeMutation
  def initialize(attributes)
    @attributes = attributes
  end

  def sampling(tbl,predicate = nil)
    sample_tbl = "ds_sample_#{tbl}"
    stats = Column_Stat.new(tbl,predicate)
    attr_stats = {}
    init_select = "select * from #{tbl} where " + (predicate.to_s.empty? ? '' : "#{predicate} AND ")
    @attributes.each do |attr|
      # binding.pry if attr.renamed_colname =='salesorderdetail_rowguid'
      attr_stats[attr.renamed_colname]=stats.get_stats(attr)
      attr_stats[attr.renamed_colname]['type']=attr.typcategory
    end
    query = attr_stats.map do |name, stat|
              if stat['type'] == 'B'
                critical_stats = ['bool_or', 'bool_and']
              else
                critical_stats = ['min', 'max']
              end
              if stat[critical_stats[0]] == stat[critical_stats[1]]
                if stat['dist_count']>1
                  stat[critical_stats[0]] = nil
                else
                  critical_stats.delete_at(0)
                end
              end
              critical_stats.map do |stat_name|
                stat_cond = "#{name} #{construct_expr(stat[stat_name],stat['type'])}"
                "(#{init_select} #{stat_cond} limit 1)"
              end.join(' UNION ')
            end.join(' UNION ')
    query = "select * from (#{query}) as tbl"
    DBConn.tblCreation(sample_tbl, '', query)
    return sample_tbl
  end

  def construct_expr(val,type)
    val.nil? ? "is null" : "= #{val.to_s.str_numeric_rep(type)}"
  end
  

  # features variable defines the kind of attributes used
  # 1---native attributes
  # 2---synthetic attributes
  # 3---both native and synthetic

  def python_training(included_tbl,excluded_tbl,dbname,script_name,is_sampling=false,included_pred=nil, features=1)
    if is_sampling
      included_sample_tbl = sampling(included_tbl,included_pred)
      excluded_sample_tbl = sampling(excluded_tbl)
    else
      included_sample_tbl = included_tbl
      excluded_sample_tbl = excluded_tbl
    end

    natvie_cols = col_name_mapping
    syn_cols = synthetic_cols()

    case features
    when 1
      cols = natvie_cols
      feature_list = @attributes
    when 2
      cols = syn_cols.map{|c| c.col_def + ' as '+ c.colname }.join(', ')
      feature_list = syn_cols
    when 3
      cols = natvie_cols +', ' +syn_cols.map{|c| c.col_def + ' as '+ c.colname }.join(', ')
      feature_list = @attributes+syn_cols
    else
      abort('unknown features')
    end

    base_name = "/Users/yguo/RubymineProjects/altar/graph/#{dbname}/#{script_name}"
    feature_file = "#{base_name}-feature"
    data_file = "#{base_name}-x.out"
    target_file = "#{base_name}-y.out"
    included_query = "(select #{cols} from #{included_sample_tbl} ) "
    excluded_query = "(select #{cols} from #{excluded_sample_tbl} )"

    Export_Data.export_feature(feature_file,feature_list)
    query = "#{included_query} union all #{excluded_query}"
    Export_Data.export_data(data_file,query)

    query = "select count(1) as cnt from #{included_query} as included"
    included_cnt = DBConn.exec(query)[0]['cnt'].to_i

    query = "select count(1) as cnt from #{excluded_query} as excluded"
    excluded_cnt = DBConn.exec(query)[0]['cnt'].to_i

    Export_Data.export_target(target_file,included_cnt,excluded_cnt)

    # system("python /Users/yguo/RubymineProjects/altar/lib/python/id3-training.py '#{dbname}' '#{script_name}'")
    # clean up
    # File.delete(data_file)
    # File.delete(target_file)
    # File.delete(feature_file)
    # File.delete(datatype_file)
  end

  def training(included_tbl,excluded_tbl)
    # cols = %w(max min).map do |stat|
    #           @attributes.map do |field|
    #             # binding.pry
    #             if field.typcategory == 'D'
    #               "#{stat}( extract( EPOCH FROM #{field.renamed_colname}) ) as #{field.renamed_colname}"
    #             else
    #               "#{stat}(#{field.renamed_colname}) as #{field.renamed_colname}"
    #             end
    #           end.join(',')
    #         end
    cols = col_name_mapping
    query = "select #{cols},1 as result from #{included_tbl}  " +
             "union all select #{cols},0 as result from #{excluded_tbl}  "
    pp query
    rst = DBConn.exec(query)
    training_data = rst.map{|r| r.values.map{|v| v.to_i} }
    pp training_data[0]
    pp cols

    attr_names = @attributes.map{|col| col.renamed_colname}
    @dec_tree = DecisionTree::ID3Tree.new(attr_names, training_data, nil, :continuous)

    startTime =  Time.now
    @node = @dec_tree.train
    endTime = Time.now
    duration = (endTime - beginTime).to_i
  end

  def col_name_mapping()
    native_cols = @attributes.map do |field|
      col_reformat(field)
    end.join(', ')
   return native_cols
    # return native_cols + ', ' + syn_cols.map{|c| c.col_def + ' as '+ c.colname }.join(', ')
    # return 
  end

  def col_reformat(column, append_colname = true)
    if column.typcategory == 'D'
        " extract( EPOCH FROM #{column.renamed_colname})" \
        + (append_colname ? " as #{column.renamed_colname}" : "")
    else
      column.renamed_colname
    end
  end

  def synthetic_cols()

    if @synthetic_cols.nil?
      @synthetic_cols = []

      @attributes.group_by {|col| col.typcategory}.each do |typcategory, colgroup|
        next if colgroup.count < 2
        colgroup.combination(2).map do |col_pair|
          syn_col = Synthetic_Column.new()
          syn_col.colname = col_pair.map{|col| col.renamed_colname}.join('_') 
          syn_col.col_def = "case when "\
          + col_pair.map{|col| col_reformat(col, false)}.join(' = ') \
          + ' then 1 else 0 end'
          @synthetic_cols << syn_col
        end
      end
      @synthetic_cols.uniq!
    end
    return @synthetic_cols
  end

  def convert_to_python_dtype(column)
    case column.typcategory 
    when 'S'
      if column.datatype.include?('(')
        length = /(\d+)/.match(column.datatype)[0]
        "S#{length}"
      else
        'S250'
      end
    when 'N'
      'i64'
    when 'D'
      'i64'
    else
      'S250'
    end

  end
end