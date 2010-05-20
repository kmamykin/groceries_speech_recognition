#!/usr/bin/env ruby

@previous_match = nil

def start_listening
# light on
end

def stop_listening
# light off
end

def indicate_readiness
# noop?
end

def say(text)
  cmd = 'echo \\(SayText \\"' + text + '\\"\\) | festival --pipe'
  puts cmd
  system(cmd)
end

def send_match(text)
  puts "Sending #{text}"
end

def cancel_previous_match
  if @previous_match
    puts "Cancelling " + @previous_match
    say("cancelling " + @previous_match)
    @previous_match = nil
  end
end

def save_match(match_text)
  if @previous_match
    send_match(@previous_match)
  end
  say("will buy " + match_text)
  @previous_match = match_text
end

def handle_recognized_utterance(text)
  case text
    when /NO/
      puts "Recognized NO"
      cancel_previous_match
    when /FUCK NO/
      puts "Recognized FUCK NO"
      say("I love you too")
      cancel_previous_match
    when /^.*BUY (.*)$/
      puts "Recognized #{$1}"
      save_match($1)
    else
      puts "Unrecognized #{text}"
      #say("huh?")
  end
end

STDIN.each_line do |line|
  case line
    when /^INFO:/
    when /^READY/
      indicate_readiness
    when /^Listening/
      start_listening
    when /^Stopped listening/
      stop_listening
    when /^\d+:/
      # parse the line in the following format:
      # 000000010: BUY ICECREAM (-13758772)
      /^\d+: (.*) \(.*\)$/.match(line)
      handle_recognized_utterance $1
    else
      puts "Unknown line: #{line}"
  end
end
