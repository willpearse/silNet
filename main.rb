#!/usr/bin/env ruby
#First (rushed) attempt
#Will - 5/3/2012

#Libraries
require 'twitter'

#Pull out the previously recorded tweets
# - make this more pleasant to read....
currentTweets = Hash.new
File.open("tweetLog2.txt") do |f|
  f.each do |line|
    entry = line.chomp.split "^"
    (currentTweets['species'] ||= []) << entry[0]
    (currentTweets['count'] ||= []) << entry[1]
    (currentTweets['lat'] ||= []) << entry[2]
    (currentTweets['long'] ||= []) << entry[3]
    (currentTweets['ID'] ||= []) << entry[4]
    (currentTweets['description'] ||= []) << entry[5]
    (currentTweets['user'] ||= []) << entry[6]
    (currentTweets['text'] ||= []) << entry[7]
  end
end

#Pull out Will's recently sent messages
tweets = Twitter.search("to:willpearse")

#Search through for un-added 'silnet' tweets
tweets.each do |tweet|
  if tweet.text.downcase.include? '#silnet'
    if not currentTweets['ID'].include? tweet.id 
      currentTweets['text'].push tweet.text
      text = tweet.text.split ","
      currentTweets['species'].push text[0]
      if text.len > 1
        currentTweets['count'].push text[1]
        if text.len > 2
          currentTweets['description'].push text[2]
        else
          currentTweets['description'].push "NA"
        end
      else
        currentTweets['count'].push "NA"
        currentTweets['description'].push "NA"
      end
      currentTweets['description'].push text[2]
      currentTweets['user'].push tweet.from_user
      currentTweets['ID'].push tweet.id
      if tweet.geo
        currentTweets['lat'].push tweet.geo.coordinates[0].to_s
        currentTweets['long'].push tweet.geo.coordinates[1].to_s
      else
        currentTweets['lat'].push "NA"
        currentTweets['long'].push "NA"
      end
    end
  end
end

#Write out new set of tweets
File.open("tweetLog.txt", 'w') do |f|
  currentTweets['ID'].each_index do |i, x|
    f.write(currentTweets['species'][i] + '^' + currentTweets['count'][i] + '^' + currentTweets['lat'][i] + '^' + currentTweets['long'][i] + '^' + currentTweets['ID'][i] + '^' + currentTweets['description'][i] + '^' + currentTweets['user'][i] + '^' + currentTweets['text'][i] + "\n")
  end
end
