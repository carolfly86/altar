# ALTAR

ALTAR is an automated SQL predicate fault localization tool.
Currently it supports PostgresSQL.

## Installation

1. `bundle install`
2. update the database config file in config/default.yml

## Usage

1. Create a directory in `/sql` directory, the name of the directory should be the database name.
2. Create a JSON file in the same format as `/sql/adventureworks/adventureworks_s01.json`
3. Execute ALTAR with this command `./test_parse.rb -s #json_file_name# -o t -g c -m r`
4. Statistics and Similarity based fault localization techniques can be applied with this command `./test_parse.rb -s #json_file_name# -o t -g c -m b` to
5. Fault localization result will be store in a table name `test_result` in your database.

## Experiment Result
1. Employees_AdventureWorks.xlsx contains experiment result for Employees and AdventureWorks
2. data_collector.xlsx, polling_etl.xlsx contians experiment result for data_collector and polling_etl database
3. balance.xlsx contains experiment result for MSDB database
4. Combined result of the 5 databases are stored in Overall.xlsx


## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
