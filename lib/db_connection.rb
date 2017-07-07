require 'yaml'
require 'pg'

module DBConn
  @cfg = YAML.load_file(File.join(File.dirname(__FILE__), '../config/default.yml'))
  @conn = PG::Connection.open(dbname: @cfg['default']['database'], user: @cfg['default']['user'], password: @cfg['default']['password'])

  def self.exec(query)
    @conn.exec(query)
  end

  def self.exec_golden_record_script(script)
    # file = File.open(script, "r")
    # contents = file.read
    # pp contents
    gr_script = "sql/golden_record/#{@cfg['default']['database']}/#{script}_gr.sql"
    system("psql -d#{@cfg['default']['database']} < #{gr_script}")
    # file.close()
  end

  def self.dump_golden_record(script)
    # file = File.open(script, "r")
    # contents = file.read
    # pp "pg_dump -t golden_record #{@cfg['default']['database']} > sql/golden_record/#{script}_gr.sql"
    system("pg_dump -t golden_record #{@cfg['default']['database']} > sql/golden_record/#{@cfg['default']['database']}/#{script}_gr.sql")
    # file.close()
  end

  def self.tblCreation(tblName, pkList, query)
    q = QueryBuilder.create_tbl(tblName, pkList, query)
    # puts q
    exec(q)
  end

  # Find all the relations(tbls) from FROM Clause including their numericDataTypes columns
  def self.getRelFieldList(fromPT)
    relNames = JsonPath.on(fromPT.to_json, '$..RANGEVAR')
    fieldsList = []
    relNames.each do |r|
      rel = {}
      relName = r['relname']
      relAlias = r['alias']
      numericDataTypes = ['smallint', 'integer', 'bigint', 'decimal', 'numeric', 'real', 'double precision', 'serial', 'bigserial']
      query = QueryBuilder.find_cols_by_data_type(relName, numericDataTypes)
      colList = exec(query).to_a
      colList.each do |c|
        fields = []
        fields << relAlias.nil? ? relName : relAlias['ALIAS']['aliasname']
        fields << c['column_name']
        fieldsList << fields
      end
    end

    fieldsList.compact
     # pp fieldsList
   end

  # Find all the relations(tbls) from FROM Clause including their columns
  def self.getAllRelFieldList(fromPT)
    relNames = JsonPath.on(fromPT.to_json, '$..RANGEVAR')
    fieldsList = []
    relNames.each do |r|
      rel = {}
      relName = r['relname']
      relAlias = r['alias']
      # numericDataTypes = ['smallint','integer','bigint','decimal','numeric','real','double precision','serial','bigserial']
      query = QueryBuilder.find_cols_by_data_typcategory(relName, '', '')
      colList = exec(query).to_a
      colList.each do |c|
        field = Column.new
        field.colname = c['column_name']
        field.relname = relName
        field.relalias = relAlias.nil? ? relName : relAlias['ALIAS']['aliasname']
        field.datatype = c['data_type']
        field.typcategory = c['typcategory']
        field.colalias = c['column_name']
        fieldsList << field
      end
    end

    fieldsList.compact
    # pp fieldsList
  end

  # Given a column in the format of ['relalias','colname'] or ['colname'],
  # Find all the relations(tbls) in FROM Clause with matching data type category
  def self.findRelFieldListByCol(fromPT, column)
    colRelName = ''
    if column.length > 1
      colRelAlias = column[0]
      colName = column[1]
      fromPT.each do |rels|
        relList = JsonPath.new('$..RANGEVAR').on(rels)
        relList.each do |rel|
          if JsonPath.new('$..aliasname').on(rel).any? { |r| r == colRelAlias }
            colRelName = JsonPath.new('$..relname').on(rel).to_a[0]
            break
          end
        end
      end
      colRelName = colRelAlias if colRelName.to_s.empty?
      query = QueryBuilder.find_cols_by_data_typcategory(colRelName, '', colName) unless colRelName.to_s.empty?
      rst = exec(query)
      colDataTypeCateory = rst.to_a[0]['typcategory'] if rst.count > 0
      # .to_a[0]['typcategory']
      # pp colDataTypeCateory
    else
      colName = column[0]
      fromPT.each do |rels|
        relList = JsonPath.new('$..RANGEVAR').on(rels)
        relList.each do |rel|
          colRelName = JsonPath.new('$..relname').on(rel).to_a[0]
          query = QueryBuilder.find_cols_by_data_typcategory(colRelName, '', colName) unless colRelName.to_s.empty?
          rst = exec(query).to_a
          if rst.count > 0
            colDataTypeCateory = rst[0]['typcategory']
            break
          end
        end
      end
    end

    relNames = JsonPath.on(fromPT.to_json, '$..RANGEVAR')
    fieldsList = []
    relNames.each do |r|
      rel = {}
      relName = r['relname']
      relAlias = r['alias']
      # numericDataTypes = ['smallint','integer','bigint','decimal','numeric','real','double precision','serial','bigserial']
      query = QueryBuilder.find_cols_by_data_typcategory(relName, colDataTypeCateory, '')
      colList = exec(query).to_a
      colList.each do |c|
        field = Column.new
        field.colname = c['column_name']
        field.relname = relName
        field.relalias = relAlias.nil? ? relName : relAlias['ALIAS']['aliasname']
        field.datatype = c['data_type']
        field.typcategory = c['typcategory']
        # field = {}

        # field['rel_alias'] = relAlias.nil? ? relName : relAlias['ALIAS']['aliasname']
        # field['rel_name'] = relName
        # field['column_name'] = c['column_name']
        # field['data_type'] = c['data_type']
        # field['typcategory'] = c['typcategory']
        fieldsList << field
      end
    end
    fieldsList.compact
    # pp fieldsList
  end

  def self.getColByDataCategory(tbl, category, col)
    query = QueryBuilder.find_cols_by_data_typcategory(tbl, category, col)
    colList = exec(query).to_a
    fieldsList = []
    colList.each do |c|
      # field = {}
      # field['column_name'] = c['column_name']
      # field['data_type'] = c['data_type']
      # field['typcategory'] = c['typcategory']
      field = Column.new
      field.colname = c['column_name']
      field.relname = tbl
      field.relalias = tbl
      field.datatype = c['data_type']
      field.typcategory = c['typcategory']
      fieldsList << field
    end
    end
end
