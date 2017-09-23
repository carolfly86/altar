require_relative 'db_connection'

module Export_Data
  def self.export_feature(filename,columns)
    File.open(filename,'w'){|f| f.write columns.map{|a| a.renamed_colname}.join("\n")}
  end

  def self.export_data(filename,select_query)
    # query = "COPY ( #{select_query} )"+
    #         "to '#{filename}' DELIMITER as '~' NULL AS ''"
    # # puts query
    # DBConn.exec(query)
    File.open(filename, "w") do |f|
      DBConn.conn.copy_data "COPY (#{select_query}) TO STDOUT CSV DELIMITER as '~' NULL AS ''" do
        while row=DBConn.conn.get_copy_data
          f.write(row)
        end
      end
    end
  end

  def self.export_target(filename,included_cnt,excluded_cnt)
    File.open(filename, "w+") do |f|
      f.puts( [1]*included_cnt + [0]*excluded_cnt )
    end
  end

end