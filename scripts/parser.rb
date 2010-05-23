#!/usr/bin/env ruby

require 'net/http'
require 'uri'

HOST = 'home-assistant.heroku.com'

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

def do_post(command, message)
  puts "Sending #{command} #{message}"
  res = Net::HTTP.post_form(URI.parse("http://#{HOST}/recognized"),
  {:command => command, :message => message.downcase})
  puts res.body
  #say("will buy " + message)
end

def send_match(text)
  @previous_match = text
  do_post('add', text)
end

def cancel_previous_match
  if @previous_match
    puts "Cancelling " + @previous_match
    do_post('delete', @previous_match)
    @previous_match = nil
  end
end

#def send_match(match_text)
##  if @previous_match
##    send_match(@previous_match)
##  end
#end

def handle_recognized_utterance(text)
  case text
    when /NO/
      puts "Recognized NO"
      cancel_previous_match
    when /CANCEL/
      puts "Recognized CANCEL"
      cancel_previous_match
    when /FUCK NO/
      puts "Recognized FUCK NO"
      say("I love you too")
      cancel_previous_match
    when /^.*BUY (.*)$/
      puts "Recognized #{$1}"
      send_match(text)
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
