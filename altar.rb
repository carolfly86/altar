#!/usr/bin/env ruby
require 'pg_query'
require 'trollop'
require 'pp'
require 'pg'
require 'yaml'
require 'json'
require 'pry'
require 'set'
Dir['lib/*.rb', 'lib/*/*.rb'].each { |file| require_relative file }
# /usr/local/Cellar/postgresql/9.3.3/bin/pg_ctl start -D/usr/local/var/postgres
# ./altar.rb -s employees_000 -g i -m or
# ./altar.rb -s employees_m06 -g i -m r -u y
# ./altar.rb -s employees_m06 -o t -g i -m o
# Dir.glob("lib/*.rb").each {|file| puts file; require_relative file }
opts = Trollop.options do
  banner 'Usage: ' + $PROGRAM_NAME + ' --script [script] '
  opt :script, 'location of sql script', type: :string
  opt :allscripts, 'process all scripts in folder (y|n)', type: :string, default: 'n'
  # opt :operation, "m(utate)|t(est)", :type => :string
  opt :golden_record, 'c(reate)|i(mport)', type: :string
  opt :method, 'o(ld)|o(ld)r(emoval)|n(ew)|b(aseline SBFL)', type: :string
  opt :autofix, 'y|n', type: :string, default: 'y'
  # opt :expectation, "location of expectation file", :type => :string
end
cfg = YAML.load_file(File.join(File.dirname(__FILE__), 'config/default.yml'))
# conn = PG::Connection.open(dbname: cfg['default']['database'], user: cfg['default']['user'], password: cfg['default']['password'])

script = opts[:script]
autofix = opts[:autofix] == 'y' ? true : false
# if opts[:operation] =='t'
if opts[:allscripts] == 'y'
  dbname = cfg['default']['database']
  create_all_script_result_tbl
  Dir["sql/#{dbname}/*.json"].each do |file|
    script = File.basename file, '.json'
    faultLocalization(script, opts[:golden_record], opts[:method], autofix)
    dump_result(script)
  end
else
  faultLocalization(script, opts[:golden_record], opts[:method], autofix)
end
# elsif opts[:operation] =='m'
# 	randomMutation(script)
# end

return
# localizeErr.similarityBitMap()
# puts tQuery.query

# generate parse tree

# Auto fix using GA
# ga = GeneticAlg.new(ps)
# prog = ga.generate_random_program()

# psNew = ps
# psNew['SELECT']['whereClause'] = prog
# pp prog

# p ReverseParseTree.reverse(psNew)
# ga.generate_neighbor_program(prog)

# pp ps
# ReverseParseTree.reverse(ps)

# find projection error
# p fQuery.table

# projErrList = localizeErr.projErr()
# pp 'Projetion Error List:'
# pp projErrList

ps = PgQuery.parse(fQuery).parsetree[0]
# Fix join Error
psNew = AutoFix.JoinTypeFix(selectionErrList['JoinErr'], ps)
# Create test tbl after fixing join errors
fQueryNew = ReverseParseTree.reverse(psNew)
fTable = 'f_result_new'
p fQueryNew
query = QueryBuilder.create_tbl(fTable, f_pkList, fQueryNew)
DBConn.exec(query)

localizeErr_aftJoinFix = LozalizeError.new(fQueryNew, fTable, tTable)
selectionErrList_aftJoinFix = localizeErr_aftJoinFix.selecionErr
pp selectionErrList_aftJoinFix

# # Auto fix using HB (only need in fixing where condition error)
# hb = HillClimbingAlg.new(ps)
# hb.generate_neighbor_program

# Auto fix using GA
# autoFix = GeneticAlg.new(ps.parsetree[0])
