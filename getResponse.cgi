#!/usr/bin/ruby
#artificial intelligence that attempts to come up with an accurate response from previous knowledge.

# inputs:
# input => user input
# lastOutput => chatbot's last output
# file => file for conversation

begin

  $: << '.' if !($:.include?('.'))

  require 'ArtificialIntelligence'
  require 'cgi'
  require 'Database'

  COMPUTER_ESCAPE = ".ESC."
  USER_ESCAPE = ".USERESC."

  cgi = CGI.new
  output = cgi['lastOutput']
  input = cgi['input']
  file_name = cgi['file']

  conversation_lines = []
  user_lines = []
  chatbot_lines = []

  if file_name && File.file?("conv/" + file_name) then
    lines = File.readlines("conv/" + file_name)
    for line in lines
      if line.strip =~ /^Our Chatbot: / then
        fixed_line = line[13..line.length-1].strip
        chatbot_lines << fixed_line
        conversation_lines << fixed_line
      else
        fixed_line = line[6..line.length-1].strip
        user_lines << fixed_line
        conversation_lines << fixed_line
      end
    end
  end

  $database = Database.new('data.txt', chatbot_lines)
  $fragment_database = Database.new('fragment_data.txt', chatbot_lines)
  ai = ArtificialIntelligence.new($database, $fragment_database)
  response = nil
  response = ai.get_best_answer(input)

  if output != COMPUTER_ESCAPE && output != USER_ESCAPE && output != input && input.strip != '' && input.strip != user_lines[-1] then
    File.open('datachanges.txt', 'a') do |f|
      f.flock(File::LOCK_EX)
      f.puts "-" + output.strip
      f.puts "  -- " + input.strip
      f.close
    end

    File.open('lastDataUpdate.txt', 'r+') do |f|
      begin
        f.flock(File::LOCK_EX)
        seconds = f.gets.to_i
        now = Time.now.to_i
        difference = now - seconds
        if difference > 5 * 60 # 5min
          f.truncate(0)
          f.pos = 0
          f.puts now.to_s
          load 'update_database.rb'
        end
      ensure
        f.flock(File::LOCK_UN)
      end
    end
  end
  
  if output != COMPUTER_ESCAPE && file_name then
    if File.file?("conv/" + file_name) || output == USER_ESCAPE then
      f = File.new("conv/" + file_name, 'a')
      f.puts "User: " + input
      f.puts "Our Chatbot: " + response
      f.close
    else
      f = File.new("conv/" + file_name, 'a')
      f.puts "Our Chatbot: " + output
      f.puts "User: " + input
      f.puts "Our Chatbot: " + response
      f.close
    end
  elsif output == COMPUTER_ESCAPE && file_name.length > 0
    f = File.new("conv/" + file_name, 'a')
    f.puts "Our Chatbot: " + response
    f.close
  end
rescue => e
  f = File.new("errorLog.txt", 'a')
  f.puts "\n\n### " + Time.new.to_s + " : " + e.to_s
  f.puts "  output:  " + output.to_s
  f.puts "  input:   " + input.to_s
  f.puts "  reponse: " + response.to_s
  f.puts "  file:    " + file_name.to_s
  f.puts e.backtrace
  f.close
ensure
  puts "Content-Type: text/plain\n\n"
  puts response
end