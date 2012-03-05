#!/usr/bin/env ruby
#First (rushed) attempt
#Will - 5/3/2012

#Libraries
require 'twitter'

#Pull out the previously recorded tweets
# - make this more pleasant to read....
currentTweets = Hash.new
currentTweets['species']=[];currentTweets['count']=[];currentTweets['lat']=[];currentTweets['lat']=[];currentTweets['long']=[];currentTweets['ID']=[];currentTweets['description']=[];currentTweets['user']=[];currentTweets['text']=[]
File.open("tweetLog.txt") do |f|
  f.each do |line|
    entry = line.chomp.split "^"
    currentTweets['species']  << entry[0]
    currentTweets['count'] << entry[1]
    currentTweets['lat'] << entry[2].to_f
    currentTweets['long'] << entry[3].to_f
    currentTweets['ID'] << entry[4].to_i
    currentTweets['description'] << entry[5]
    currentTweets['user'] << entry[6]
    currentTweets['text'] << entry[7]
  end
end

#Pull out Will's recently sent messages
tweets = Twitter.search("to:silwoodnet")

#Search through for un-added 'silnet' tweets
tweets.each do |tweet|
  if not currentTweets['ID'].include? tweet.id
    currentTweets['text'].push tweet.text
    text = tweet.text.split ","
    text[0].sub('@silwoodnet', '')
    currentTweets['species'].push text[0]
    if text.length > 1
      currentTweets['count'].push text[1]
      if text.length > 2
        currentTweets['description'].push text[2]
      else
        currentTweets['description'].push "NA"
      end
    else
      currentTweets['count'].push "NA"
      currentTweets['description'].push "NA"
    end
    currentTweets['user'].push tweet.from_user
    currentTweets['ID'].push tweet.id
    if tweet.geo
      currentTweets['lat'].push tweet.geo.coordinates[0]
      currentTweets['long'].push tweet.geo.coordinates[1]
    else
      currentTweets['lat'].push -9999999.9
      currentTweets['long'].push -9999999.9
    end
  end
end

#Write out new set of tweets
File.open("tweetLog.txt", 'w') do |f|
  currentTweets['ID'].each_index do |i, x|
    f.write(currentTweets['species'][i] + '^' + currentTweets['count'][i] + '^' + currentTweets['lat'][i].to_s + '^' + currentTweets['long'][i].to_s + '^' + currentTweets['ID'][i].to_s + '^' + currentTweets['description'][i] + '^' + currentTweets['user'][i] + '^' + currentTweets['text'][i] + "\n")
  end
end
