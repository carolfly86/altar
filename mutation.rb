
require 'pg_query'
require 'trollop'
require 'pp'
require 'pg'
require 'yaml'
require 'json'
require 'pry'
require_relative 'lib/query_t'
require_relative 'lib/localizeError'
require_relative 'lib/reverse_parsetree'
require_relative 'lib/genetic_alg'
require_relative 'lib/hill_climbing'
require_relative 'lib/autofix'
require_relative 'lib/query_builder'
require_relative 'lib/db_connection'
require_relative 'lib/sql_mutation'
require_relative 'lib/utils'
require_relative 'lib/column'
opts = Trollop.options do
  banner 'Usage: ' + $PROGRAM_NAME + ' --script [script] '
  opt :script, 'location of sql script', type: :string
  opt :expectation, 'location of expectation file', type: :string
end
# query = File.read("sql/#{opts[:script]}")
# parseTree = PgQuery.parse(query).parsetree[0]
# mutation = SqlMutation.new(parseTree)
# p mutation.constMutation(parseTree)
