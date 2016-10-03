# ALTAR

ALTAR is an automated SQL predicate fault localization tool.
Currently it supports PostgresSQL.

## Installation

1. `bundle install`
2. update the database config file in config/default.yml
## Usage

1. Create a directory in `/sql` directory, the name of the directory should be the database name.
2. Create a JSON file in the same format as `/sql/adventureworks/adventureworks_s01.json`
3. Execute ALTAR with this command `./test_parse.rb -s #json_file_name# -o t -g c -b y`
4. Result of ALTAR will be store in a table name `test_result` in your database.

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
