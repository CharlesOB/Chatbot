# make fragment associations

$: << '.' if !($:.include?('.'))

require 'Database'
require 'ArtificialIntelligence'

def get_full_match(words1, words2, start1, start2)
  match = []
  i = start1
  j = start2
  while i < words1.size && j < words2.size
    if words1[i] == words2[j] then
      match << words1[i]
    else
      break
    end
    i += 1
    j += 1
  end
  return match
end

def get_matches(words1, words2)
  matches = []
  i = 0
  while i < words1.size
    if words2.include?(words1[i]) then
      start2 = words2.index(words1[i])
      match = get_full_match(words1, words2, i, start2)
      matches << match if !(matches.include?(match))
      i += match.size
    else 
      i += 1
    end
  end
  return matches
end



ai = ArtificialIntelligence.new(nil, nil)

all_data = (Database.new('data.txt', [])).get_all_data

fragment_data = {}


for key in all_data.keys
  associations = []
  key_words = key.split
  key_words_fixed = key_words.collect {|word| ai.remove_suffix(word)}
  for value in all_data[key]
    prepared_value = ai.prepare(value)
    switched_value = ai.switch_pronouns(prepared_value)
    value_words = switched_value.split
    value_words2 = prepared_value.split
    value_words_fixed = value_words.collect {|word| ai.remove_suffix(word)}
    value_words_fixed2 = value_words2.collect {|word| ai.remove_suffix(word)}
    matches = get_matches(key_words_fixed, value_words_fixed)
    matches2 = []
#    matches2 = get_matches(key_words_fixed, value_words_fixed2)
    total_matches = matches
    for match in matches2
      total_matches << match if !(total_matches.include?(match))
    end
    associations << {:value => value, :matches => total_matches}
  end

  matches_sorted = {}
  for match_association in associations
    for match in match_association[:matches]
      if matches_sorted.has_key?(match) then
        matches_sorted[match] << match_association[:value]
      else
        matches_sorted[match] = [match_association[:value]]
      end
    end
  end

  for fragment_parts, values in matches_sorted
    if fragment_parts.size > 1 then
      fragment = fragment_parts.join(' ')
      if !(fragment_data.has_key?(fragment)) then
        fragment_data[fragment] = []
      end
      for value in values
        fragment_data[fragment] << value
      end
    end
  end
end

fragment_database = Database.new('fragment_data.txt', [])
fragment_database.data = fragment_data
fragment_database.dump_data
