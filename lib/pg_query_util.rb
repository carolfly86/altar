class PgQuery
   def find_location(tree=@parsetree[0], locVal)
    keys = tree.keys
    result = []
    keys.each do |key|
      value = tree[key]
      if key == 'location'
        if tree[key].to_s == locVal
          result << tree 
        end
      else
        if value.is_a? Array
          value.each do |v|
            result << find_location(v,locVal) if v.is_a? Hash
          end
        else
          result << find_location(value,locVal) if value.is_a? Hash  
        end
      end
    end
    result.flatten
  end

  def replace_at_location(tree=@parsetree[0], locVal, replacement)
    keys = tree.keys
    result = []
    keys.each do |key|
      value = tree[key]
      if key == 'location'
        if tree[key].to_s == locVal
          result << tree 
        end
      else
        if value.is_a? Array
          value.each do |v|
            result << find_location(v,locVal) if v.is_a? Hash
          end
        else
          result << find_location(value,locVal) if value.is_a? Hash  
        end
      end
    end
    result.flatten
  end
end