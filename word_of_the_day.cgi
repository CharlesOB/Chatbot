#!/usr/bin/ruby

require "yaml"
require "cgi"

$file_name = "wordOfTheDay.txt"
$data = YAML::load(File.readlines($file_name).join)

def get_references(word)
  if $data.has_key?(word)
    return $data[word]
  else
    return 0
  end
end
 
def add_references(word, howMany)
  if $data.has_key?(word)
    $data[word] += howMany
  else
    $data[word] = howMany
  end
  return $data[word]
end
  
def dump_data
  f = File.new($file_name, 'w')
  f.puts $data.to_yaml
  f.close
end

cgi = CGI.new

puts "Content-Type: text/plain\n\n"

if cgi['times'].to_i < 1 then
  puts get_references(cgi['word'])
else
  puts add_references(cgi['word'], cgi['times'].to_i)
  dump_data
end