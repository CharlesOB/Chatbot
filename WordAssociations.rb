# This class is used to store the word_associations made in word_associations.rb
class WordAssociations

  attr_accessor :data

  @@KEY_SEP = ": "
  @@PAIR_SEP = ", "
  @@DATUM_SEP = "|"

  def initialize(file_name)
    @file_name = file_name
    @data = nil
    retrieve_data
  end
  
  def dump_data
    File.open(@file_name, 'w') do |f|
      for key in data.keys.sort
        f.print key + @@KEY_SEP
        f.print data[key].sort.map {|word, percent| word + @@DATUM_SEP + percent.to_s}.join @@PAIR_SEP
        f.print "\n"
      end
    end
  end
  
  def retrieve_data
    @data = {}
    if File.file?(@file_name) then
      lines = File.readlines(@file_name)
      for line in lines
        line.force_encoding(Encoding::UTF_8)
        key, values = line.chop.split @@KEY_SEP
        @data[key] = {}
        values.split(@@PAIR_SEP).each do |pair|
          word, percent = pair.split @@DATUM_SEP
          @data[key][word] = percent.to_f
        end
      end
    end
    return true
  end
  
  def get_all_data
    return @data
  end
  
  def get_related_words(word)
    return @data[word] || {}
  end
  
  def get_related_words_table(word_list)
    table = {}
    num_tables = word_list.size
    for word in word_list
      rel_words = get_related_words(word)
      num_tables -= 1 if rel_words.empty?
      for word2, percent in rel_words
        if table.has_key?(word2) then
          table[word2] += percent
        else
          table[word2] = percent
        end
      end
    end
    if num_tables > 0 then
      for word, percent in table
        table[word] = percent / num_tables.to_f
      end
    end
    return table
  end

end
