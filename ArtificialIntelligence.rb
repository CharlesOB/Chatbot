$: << '.' if !($:.include?('.'))
require 'yaml'
require 'WordAssociations'

class ArtificialIntelligence

  def initialize(database, fragment_database)
    @bad_words = %w{damn shit fuck fucker dick penis rape sex cock ass vagina pis bitch fag faggot lesbian gay cunt cum porn pornography suk bullshit bs boner puta gilipoyas poyas pene cono conos penes poyas estupido mierda follar empalar cagar cago meas mear puto putos putas culo maricon maricona}
    @contractions = YAML::load(File.readlines("contractions.txt").join)
    @prepositions = File.readlines("prepositions.txt")
    @prepositions = @prepositions.collect {|prep| prep.strip }
    @word_associations = WordAssociations.new('word_data.txt')
    @database = database
    @fragment_database = fragment_database
  end

  def get_best_answer(input)
    prepared_input = prepare(input)
    data = @database.get_partial_data
    fragment_data = @fragment_database.get_partial_data
    possible_outputs = nil
    best_phrases = nil
    if data.has_key?(prepared_input) && data[prepared_input] != [] then
      possible_outputs = data[prepared_input]
      answer = possible_outputs[rand(possible_outputs.size)]
      return answer
    else
      catch :there_is_an_answer do
        data_keys = data.keys
        fragments = fragment_data.keys
        
        best_phrases = find_string_inside(prepared_input, data_keys, 0.40)
        possible_outputs = get_possible_outputs(best_phrases, data)
        throw :there_is_an_answer if possible_outputs

        best_frags = match_fragments(prepared_input, fragments)
        longest_frag = longest(best_frags)
        if longest_frag != nil then
          possible_outputs = get_possible_outputs([longest_frag], fragment_data)
#          f = File.new('fraguse.txt', 'a')
#          f.puts "\n\n\"" + input + "\" matched: " + best_frags.join("\n\t")
#          f.puts "Longest: " + longest_frag
#          f.puts "Used fragment to get: " + possible_outputs.join("\n\t")
#          f.close
          throw :there_is_an_answer
        end

        best_phrases = find_string_outside(prepared_input, data_keys, 0.40)
        possible_outputs = get_possible_outputs(best_phrases, data)
        throw :there_is_an_answer if possible_outputs

        best_phrases = match_bigrams(prepared_input, data_keys, 0.10)
        possible_outputs = get_possible_outputs(best_phrases, data)
        throw :there_is_an_answer if possible_outputs

        best_phrases = match_individual_words(prepared_input, data_keys, 0.00)
        possible_outputs = get_possible_outputs(best_phrases, data)
        throw :there_is_an_answer if possible_outputs

        best_phrases = ["hello"]
        possible_outputs = get_possible_outputs(best_phrases, data)
      end
    end
    answer = get_best_output(prepared_input, possible_outputs)
    return answer
  end

  def get_key_for_value(keys, value, data)
    for key in keys
      return key if data[key].include?(value)
    end
  end

  def get_possible_outputs(best_phrases, data)
    possible_outputs = nil
    if !(best_phrases.empty?) then
      best_phrase = shortest(best_phrases)
      possible_outputs = data[best_phrase]
    end
    return possible_outputs
  end

  def get_best_output_based_on_input(prepared_input, outputs, tolerance=0.05)
    percent = 2.00 #200%
    best_outputs = []
    switched_input = switch_pronouns(prepared_input)
    words = switched_input.split
    words = words.collect {|word| remove_suffix(word)}
    for output in outputs
      output_words = output.split
      num_matches = 0
      for output_word in output_words
        for word in words
          if word == remove_suffix(output_word) then
            num_matches += 1
            break
          end
        end
      end
      new_percent = (output_words.size - num_matches) / output_words.size.to_f
      if new_percent < percent - tolerance then
        percent = new_percent
        best_outputs = [output]
      elsif new_percent < percent + tolerance && new_percent > percent - tolerance then
        best_outputs << output
      end
    end
    return best_outputs[rand(best_outputs.size)]
  end
  
  def get_best_output(prepared_input, outputs)
    best_outputs = []
    best_score = -99999999999
    words = prepared_input.split.collect {|word| remove_suffix(word)}
    table = @word_associations.get_related_words_table(words)
    for output in outputs
      output_words = prepare(output).split.collect {|word| remove_suffix(word)}
      score = 0
      for word in output_words
        if table.has_key?(word) then
          score += table[word]
        end
      end
      if best_outputs.size < 1 then
        best_outputs << output
        best_score = score
      else
        if score == best_score then
          best_outputs << output
        elsif score > best_score then
          best_outputs = [output]
          best_score = score
        end
      end
    end
    if best_score == 0 then
      return get_best_output_based_on_input(prepared_input, outputs)
    else
      return best_outputs[rand(best_outputs.size)]
    end
  end

  def shortest(strings)
    if strings.empty? then
      return nil
    else
      shortest = strings[0]
      for string in strings
        shortest = shortest.length > string.length ? string : shortest
      end
      return shortest
    end
  end

  def longest(strings)
    if strings.empty? then
      return nil
    else
      longest = strings[0]

      for string in strings
        longest = longest.length < string.length ? string : longest
      end
      return longest
    end
  end

  def find_string_inside(input, data_keys, percent) #check to see if the input includes a key in the data.
    good_keys = []
    for key in data_keys
      if input.include?(key)
        if (key.length / input.length) > percent then
          good_keys << key
        end
      end
    end
    return good_keys
  end

  def find_string_outside(input, data_keys, percent) #check to see if any keys in the data include the input.
    good_keys = []
    for key in data_keys
      if key.include?(input)
        if (input.length / key.length) > percent then
          good_keys << key
        end
      end
    end
    return good_keys
  end

  def add_to_data(key, value)
    prepared_key = prepare(key.to_s)	# makes sure the Strings are not Webrick Strings
    prepared_value = value
    if prepared_value != "thinking" && is_short_enough?(prepared_value) && !has_spam?(prepared_value) && !has_bad_words?(prepared_value) then
      @database.append(prepared_key, value.to_s)
    end
  end

  def is_short_enough?(input)
    return input.length <= 200
  end

  def has_spam?(input)
    for word in input.split
      if word.length > 15 then
        return true
      elsif word.length == 1 && word != 'i' && word != 'a' && word != 'I' && word != 'A'
        return true
      end
    end
    return false
  end

  def has_bad_words?(input)
    for word in input.split
      for bad_word in @bad_words
        return true if match?(word, bad_word)
      end
    end
    return false
  end

  def prepare(string)
    prepared_string = string.gsub(/(,|\.|\?|!|"|'|:|;|`|~|@|#|\$|%|\^|&|\*|\(|\)|\[|\]|\{|\}|<|>|\\|\/|\|)/, "")
    prepared_string = prepared_string.gsub(/\s+/, " ").downcase
    prepared_string = replace_contractions(prepared_string)
    return prepared_string
  end

  def match?(string1, string2)
    if !((string1 == 'i' || string1 == 'a') || (string2 == 'a' || string2 == 'i'))
      new_string1 = remove_suffix(string1)
      new_string2 = remove_suffix(string2)
      return new_string1 == new_string2
    else
      return string1 == string2
    end
  end

  def make_bigrams(string)
    bigrams = []
    words = string.split
    (words.size-1).times do |i|
      bigrams << [words[i], words[i+1]]
    end
    return bigrams
  end

  def replace_contractions(string) # Precondition: string has no punctuation or capitalization
    words = string.split
    new_words = []
    for word in words
      if @contractions.has_key?(word) then
        word = @contractions[word]
      end
			# Some contractions had to be omitted due to ambiguity of meaning:
			# ain't, he'll, i'll, it's, she'd, she'll, we'd, we'll, we're
			# Most contractions using y'all were omitted.
      new_words << word 
    end
    return new_words.join(" ")
  end

  def switch_pronouns(string) # Precondition: string has no punctuation or capitalization or extra spaces
    words = string.split	# This whole method can still be fixed to cover questions like "Are you?" => "Am I?"
    words.size.times do |i|
      word = words[i]
      if word == "i" then
        if i+1 < words.size then
          next_word = words[i+1]
          if next_word == "am" then
            words[i+1] = "are"
          elsif next_word == "was" then
            words[i+1] = "were"
          end
        end
        words[i] = "you"
      elsif word == "you" then
        words[i] = "i"
        used_me = false
        if i-1 >= 0 then
          previous_word = words[i-1]
          if @prepositions.include?(previous_word) then
            words[i] = "me"
            used_me = true
          end
        end
        if i+1 < words.size && !used_me then
          next_word = words[i+1]
          if next_word == "are" then
            words[i+1] = "am"
          elsif next_word == "were" then
            words[i+1] = "was"
          end
        end
      elsif word == "your"
        words[i] = "my"
      elsif word == "yours"
        words[i] = "mine"
      elsif word == "my"
        words[i] = "your"
      elsif word == "mine"
        words[i] = "yours"
      end
    end
    return words.join(" ")
  end

  def remove_suffix(word)
    if word.end_with?('ies') then
      new_word = word.chop.chop.chop + 'y'
      return new_word
    elsif word.end_with?('es') then
      new_word = word.chop.chop
      return new_word
    elsif word.end_with?('s') then
      if word.end_with?('ss') or word.length < 3 then
        return word
      else
        new_word = word.chop
        return remove_suffix(new_word)
      end
    elsif word.end_with?('ing') then
      if word.length > 5 then
        new_word = word.chop.chop.chop
        return word
      else
        return word
      end
    elsif word.end_with?('ed') then
      if word.length > 4 then

        new_word = word.chop.chop
        return new_word
      else
        return word
      end
    else
      return word
    end
  end

  def match_bigrams(input, data_keys, percent)
    best_phrases = {:phrases => [], :num_of_matched => -1}
    fixed_input = (input.split.collect {|word| remove_suffix(word)}).join(" ")
    input_bigrams = make_bigrams(fixed_input)
    for key in data_keys
      num_matched_bigrams = 0
      fixed_key = (key.split.collect {|word| remove_suffix(word)}).join(" ")
      key_bigrams = make_bigrams(fixed_key)
      for input_bigram in input_bigrams
        for key_bigram in key_bigrams
          if input_bigram[0].to_s == key_bigram[0].to_s && input_bigram[1].to_s == key_bigram[1].to_s then
            num_matched_bigrams += 1
            break
          end
        end
      end
      if num_matched_bigrams > best_phrases[:num_of_matched] then
        best_phrases = {:phrases => [key], :num_of_matched => num_matched_bigrams}
      elsif num_matched_bigrams == best_phrases[:num_of_matched] then
        best_phrases[:phrases] << key
      end
    end
    if best_phrases[:num_of_matched].to_f / input_bigrams.size >= percent then
      return best_phrases[:phrases]
    else 
      return []
    end
  end

  def match_individual_words(input, data_keys, percent)
    best_phrases = {:phrases => [], :num_of_matched => -1}
    input_words = input.split
    input_words = input_words.collect {|word| remove_suffix(word)}
    for key in data_keys
      num_of_matched_words = 0
      key_words = key.split
      for word in input_words
        if word != ''
          for key_word in key_words
            suffix_removed_keyword = remove_suffix(key_word)
            if word == suffix_removed_keyword then
              num_of_matched_words += 1
              break
            end
          end
        end
      end
      if num_of_matched_words > best_phrases[:num_of_matched] then
        best_phrases = {:phrases => [key], :num_of_matched => num_of_matched_words}
      elsif num_of_matched_words == best_phrases[:num_of_matched] then
        best_phrases[:phrases] << key
      end
    end
    if best_phrases[:num_of_matched].to_f / input_words.size >= percent then
      return best_phrases[:phrases]
    else 
      return []
    end
  end

  def match_fragments(input, fragments)
    best_frags = []
    fixed_input = (input.split.collect {|word| remove_suffix(word)}).join(' ')
    for frag in fragments
      if fixed_input.include?(frag) then
        best_frags << frag
      end
    end
    return best_frags
  end

  def match_relevance_table(input, data_keys)
    input_words = input.split.collect {|word| remove_suffix(word)}
    table = @word_associations.get_related_words_table(input_words)
    best_keys = []
    best_score = 0
    for key in data_keys
      key_words = key.split.collect {|word| remove_suffix(word)}
      score = 0
      for word in key_words
        if table.has_key?(word) then
          score += table[word]
        end
      end
      score /= key_words.size.to_f
      if best_keys.size < 1 then
        best_keys << key
        best_score = score
      else
        if score == best_score then
          best_keys << key
        elsif score > best_score then
          best_keys = [key]
          best_score = score
        end
      end
    end
    if best_score == 0 then
      return match_individual_words(input, data_keys, 0.00)
    else
      return best_keys
    end
  end
  private :get_best_output, :make_bigrams, :match_individual_words, :match_bigrams, :match?, :is_short_enough?, :has_spam?, :has_bad_words?, :find_string_inside, :find_string_outside, :get_possible_outputs

end
