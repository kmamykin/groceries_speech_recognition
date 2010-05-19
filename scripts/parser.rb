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
    puts "Cancelling"
    @previous_match = nil
  end
end

def save_match(match_text)
  if @previous_match
    send_match(@previous_match)
  end
  @previous_match = match_text
end

def handle_recognized_utterance(text)
  case text
    when /NO/
      puts "Recognized NO"
      cancel_previous_match
      say("ok")
    when /FUCK NO/
      puts "Recognized FUCK NO"
      cancel_previous_match
      say("I love you too")
    when /^.*BUY (.*)$/
      puts "Recognized #{$1}"
      say($1)
      save_match($1)
    else
      puts "Unrecognized #{text}"
      say("I am sorry I cant do that")
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
