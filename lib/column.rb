class Column
	attr_accessor :colname, :relname, :relalias, :datatype, :typcategory, :colalias
	attr_reader :fullname, :expr, :renamed_colname
	def fullname
		# relalias.colname
		@fullname = @relalias.to_s.empty? ? @colname : "#{@relalias}.#{@colname}" 
		# @expr = @colalias.to_s.empty? ? @expr : "#{@expr} as #{@colalias}"
	end
    def renamed_colname
        # relname_colname
        @renamed_colname = "#{@relname}_#{@colname}" 
    end
	def expr
		# relalias.colname as colalias
		@expr = @colalias.to_s.empty? ? self.fullname : "#{self.fullname} as #{@colalias}"
	end
	def columnRef
		relname = relalias.nil? ? @relname : @relaias
		[relname, @colname]
	end

	def != (other)
		if other.class == self.class
		    self.columnRef != other.columnRef
		else
		    false
		end
	end

	def == (other)
		if other.class == self.class
		    @relname  == other.relname and @colname == other.colname
		else
		    false
		end
	end
    def eql? (other)
        if other.class == self.class
            @relname  == other.relname and @colname == other.colname
        else
            false
        end
    end
    def hash
        [@relname,@colname].hash
    end
    # Given a Column object
    # Find the relname the column belongs to from provided from PT
    def updateRelname(fromPT)

        relNames = JsonPath.on(fromPT.to_json, '$..RANGEVAR')
        # pp relNames
    	# column has no relalias or relname 
    	relNames.each do |rel|
    		tblName = rel['relname']
            tblAlias = rel['alias'].nil? ? nil : rel['alias']['ALIAS']['aliasname']
            # pp tblName
            # pp tblAlias
            # if @relaias already exists, we only query on matching relialia
            if not @relalias.to_s.empty? and tblName != @relalias and tblAlias !=  @relalias
                # pp 'searching for matching @relalias'
                # binding.pry
                next
            end
            query = QueryBuilder.find_cols_by_data_typcategory(tblName,'',@colname)
            res = DBConn.exec(query)
            # pp res
            if res.count()>0
                # pp res[0]
                r = res[0]
                @relname = tblName
                @datatype = r['data_type']
                @typcategory = r['typcategory']
                # puts 'rel'
                # pp rel
                if rel.has_key?('alias') 
                    unless rel['alias'].nil?
                        @relalias = rel['alias']['ALIAS']['aliasname']
                    else
                        @relalias = nil
                    end
                end
                return
            end
    	end
    end
end