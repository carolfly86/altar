require 'pg_query'
require_relative 'table'

class ParseTree
  def initialize(query)
    @parse_tree = PgQuery.parse(query).parsetree[0]
    @from_pt = @parse_tree['SELECT']['fromClause'][0]
    @where_clause = @parse_tree['SELECT']['whereClause']
  end

  def join_list()
    if @join_list.nil?
      @join_list = []
      if has_join?()
        @join_list =[]
        from_pt = @parse_tree['SELECT']['fromClause'][0]
        rel_list = rel_list()
        join_list = JsonPath.on(from_pt, '$..JOINEXPR')
        id = join_list.count() -1
        join_list.each do |join|
          j = {}
          l_rel_list = JsonPath.on(join['larg'],'$..relname')
          r_rel_list = JsonPath.on(join['rarg'],'$..relname')
          j['jointype'] = join['jointype']
          j['l_rel_list'] = rel_list.select{|rel| l_rel_list.include?(rel.relname)}
          j['r_rel_list'] = rel_list.select{|rel| r_rel_list.include?(rel.relname)}
          j['jointype'] = join['jointype']
          j['quals'] = join['quals']
          j['id'] = id
          @join_list << j
          id = id -1
        end
      end
    end
    return @join_list
  end

  def has_join?()
    return @from_pt.keys.include?('JOINEXPR')
  end

  def has_where_predicate?()
    return (not @where_clause.nil?)
  end

  def join_types()
    if has_join?()
      return JsonPath.on(@from_pt.to_json, '$..jointype')
    else
      return []
    end
  end

  def rel_list()
    if @rel_list.nil?
      # from_pt = @parseTree['SELECT']['fromClause'][0].to_json
      @rel_list = []

      self.rel_names.each do |tbl|
        relname = tbl['relname']
        relalias = tbl['alias'].nil? ? nil : tbl['alias']['ALIAS']['aliasname']

        table = Table.new(relname)
        table.relalias = relalias

        @rel_list << table unless @rel_list.include?(table)
      end
    end
    return @rel_list
  end

  def rel_names
    @rel_names ||= JsonPath.on(@parse_tree['SELECT']['fromClause'].to_json, '$..RANGEVAR')
  end
end
