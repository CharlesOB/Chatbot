# Make word associations.

$: << '.' if !($:.include?('.'))

require 'Database'
require 'ArtificialIntelligence'
require 'WordAssociations'

$ai = ArtificialIntelligence.new(nil, nil)
$common_words = File.readlines('common_words.txt')
$common_words.delete "\n"
$common_words = $common_words.collect {|word| $ai.remove_suffix(word.chop) }

$word_associations = {}


def remove_common_words(words_list)
  result_list = []
  for word in words_list
    if !$common_words.include?(word)
      result_list << word
    end
  end
  return result_list
end

def get_words_fixed(string)
  words = $ai.prepare(string).split.collect {|word| $ai.remove_suffix(word)}
  return remove_common_words(words)
end

def add_word_association(word1, word2) # returns true if the word was added. false otherwise.
  return false if word1 == word2
  if $word_associations.has_key? word1 then
    $word_associations[word1] << word2
  else
    $word_associations[word1] = [word2]
  end
  return true
end

all_data = (Database.new('data.txt', [])).get_all_data

for key in all_data.keys
  key_words_fixed = get_words_fixed(key)
  key_words_fixed.size.times do |i|
    word1 = key_words_fixed[i]
    (i+1).upto(key_words_fixed.size-1) do |j|
      word2 = key_words_fixed[j]
      add_word_association(word1, word2)
      add_word_association(word2, word1)
    end
  end
  for value in all_data[key]
    value_words_fixed = get_words_fixed(value)
    value_words_fixed.size.times do |i|
      word1 = value_words_fixed[i]
      (i+1).upto(value_words_fixed.size-1) do |j|
        word2 = value_words_fixed[j]
        add_word_association(word1, word2)
        add_word_association(word2, word1)
      end
    end
    for key_word in key_words_fixed
      for value_word in value_words_fixed
        add_word_association(key_word, value_word)
      end
    end
  end
end

for key in $word_associations.keys
  percents = {}
  total_words = $word_associations[key].size.to_f
  for word in $word_associations[key]
    if percents.has_key? word
      percents[word] += 1.0
    else
      percents[word] = 1.0
    end
  end
  for word in percents.keys
    percents[word] /= (total_words / 100) # turns into a percentage out of 100%
  end
  $word_associations[key] = percents
end

wa = WordAssociations.new('word_data.txt')
wa.data = $word_associations
wa.dump_data

