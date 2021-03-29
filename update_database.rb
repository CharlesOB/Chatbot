# add all changes in datachanges.txt to data.txt and rerun frag_associations.rb

$: << '.' if !($:.include?('.'))
require 'Database'
require 'ArtificialIntelligence'

database = Database.new('data.txt', [])
fragment_database = Database.new('fragment_data.txt', [])
ai = ArtificialIntelligence.new(database, fragment_database)

key = 'hello'
value = 'hello'

File.open('datachanges.txt', 'r+') do |f|
  f.flock(File::LOCK_EX)
  loop do
    begin
      break if not line = f.gets
      line.force_encoding(Encoding::UTF_8)
      if line.start_with?('-') then
        key = line[1..line.length].strip
      elsif line.start_with?('  -- ') then
        value = line[4..line.length].strip
        ai.add_to_data(key, value)
      end
    rescue
      # do nothing for now...
    end
  end
  f.truncate(0)
  f.pos = 0
end

database.dump_data

load "frag_associations.rb"
load "word_associations.rb"
