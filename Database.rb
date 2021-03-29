class Database
  attr_accessor :data

  def initialize(file_name, used_responses)
    set_up
    @file_name = file_name
    retrieve_data(used_responses)
  end

  def set_up
    @data = nil
    @partial_data = nil
    @file_name = nil
  end

  def retrieve_data(used_responses)
    @data = {}
    @partial_data = {}
    if File.file?(@file_name) then
      lines = File.readlines(@file_name)
      key = "hello"
      for line in lines
        line.force_encoding(Encoding::UTF_8)
        if line.start_with?(' - ') then
          value = line[3..line.length-1].strip
          @data[key] << value
          @partial_data[key] << value if !(used_responses.include?(value))
        else
          key = line.strip
          @data[key] = []
          @partial_data[key] = []
        end
      end
      for key in @partial_data.keys
        @partial_data.delete(key) if @partial_data[key].empty?
      end
    end
    return true
  end

  def dump_data
    file = File.new(@file_name, 'w')
    for key in @data.keys
      file.puts key
      for value in @data[key]
        file.puts " - " + value
      end
    end
    file.close
  end

  def append(key, value)
    if @data.has_key?(key) then
      @data[key] << value
    else
      @data[key] = [value]
    end
  end

  def get_all_data
    return @data.dup
  end

  def get_partial_data
    return @partial_data.dup
  end

  private :set_up, :retrieve_data

end
