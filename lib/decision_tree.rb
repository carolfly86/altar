require 'decisiontree'
require_relative 'db_connection'

class DecisionTreeMutation
  def initialize(attributes)
    @attributes = attributes
  end

  def python_training(included_tbl,excluded_tbl,dbname,script_name)
    cols = col_name_mapping
    base_name = "/Users/yguo/RubymineProjects/altar/graph/#{dbname}/#{script_name}"
    feature_file = "#{base_name}-feature"
    File.open(feature_file,'w'){|f| f.write @attributes.map{|a| a.renamed_colname}.join("\n")}

    data_file = "#{base_name}-x.out"
    target_file = "#{base_name}-y.out"
    query = "COPY ( (select #{cols} from #{included_tbl} limit 10)" +
            "union all (select #{cols} from #{excluded_tbl} limit 10) ) "+
            "to '#{data_file}'"
    pp query
    DBConn.exec(query)
    query = "COPY ( (select 1 from #{included_tbl} limit 10) " +
            "union all (select 0 from #{excluded_tbl} limit 10) ) "+
            "to '#{target_file}'"
    pp query
    DBConn.exec(query)

    system("python /Users/yguo/RubymineProjects/altar/lib/python/id3-training.py '#{dbname}' '#{script_name}'")
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

  def col_name_mapping
    @attributes.map do |field|
      if field.typcategory == 'D'
        " extract( EPOCH FROM #{field.renamed_colname}) as #{field.renamed_colname}"
      else
        field.renamed_colname
      end
    end.join(', ')
  end
end