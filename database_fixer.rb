#removes all '' in the values of the database and removes all contractions in keys.

$: << '.'

require 'Database'
require 'ArtificialIntelligence'

$database = Database.new('data.txt', [])

data = $database.get_all_data

new_data = {}

ai = ArtificialIntelligence.new(nil, nil)

for key in data.keys
  data[key].delete('')
  new_data[ai.prepare(key)] = data[key]
end

$database.data = new_data
$database.dump_data
