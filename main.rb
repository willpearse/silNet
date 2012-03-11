#!/usr/bin/env ruby
#First (rushed) attempt
#Will - 5/3/2012

#Libraries
require 'twitter'

#Pull out the previously recorded tweets
# - make this more pleasant to read....
currentTweets = Hash.new
currentTweets['species']=[];currentTweets['count']=[];currentTweets['lat']=[];currentTweets['lat']=[];currentTweets['long']=[];currentTweets['ID']=[];currentTweets['description']=[];currentTweets['user']=[];currentTweets['text']=[];currentTweets['timecode']=[]
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
    currentTweets['timecode'] << entry[7]
    currentTweets['text'] << entry[8]
  end
end

#Check to see if we need to do something else...

if ARGV[0]
  if ARGV[0] == 'userGraph'
    require 'gchart'
    require 'launchy'
    users = Hash.new(0)
    currentTweets['user'].each do |user|
      users[user] += 1
    end
    users = Hash[users.sort]
    Launchy.open Gchart.bar(:data => users.values.sort, :axis_with_labels => 'y', :size => '600x400')
  elsif ARGV[0] == 'stats'
    total = 0
    currentTweets['lat'].each do |lat|
      if lat > 0
        total += 1
      end
    end
      puts "Total tweets: #{currentTweets['lat'].length}"
      puts "Total geo-cached tweets: #{total}"
      fraction = (Float(total) / currentTweets['lat'].length)*100
      puts "... #{fraction.round(0)}% geo-cached"
  end
else
  #Pull out SilNet's recently sent messages
  tweets = Twitter.search("to:silwoodnet")
  #Search through for un-added 'silnet' tweets
  currentNew = 0
  tweets.each do |tweet|
    if not currentTweets['ID'].include? tweet.id
      currentNew += 1
      currentTweets['text'].push tweet.text
      text = tweet.text.sub('@silwoodnet', '')
      if text.include? ','
        text = text.split(',')
        currentTweets['species'].push text[0]
        if text[1].include? '-'
          text = text[1].split '-'
          currentTweets['count'].push text[0].to_i
          currentTweets['description'].push text[1]
        else
         currentTweets['count'].push text[1].to_i
         currentTweets['description'].push "NA"
       end
     elsif text.include? '-'
       text = text.split('-')
       currentTweets['species'].push text[0]
       currentTweets['count'].push -99999
       currentTweets['description'].push text[1]
     else
       currentTweets['species'].push text
       currentTweets['count'].push -99999
       currentTweets['description'].push "NA"
     end
      if tweet.geo
        currentTweets['lat'].push tweet.geo.coordinates[0]
        currentTweets['long'].push tweet.geo.coordinates[1]
      else
        currentTweets['lat'].push -9999999.9
        currentTweets['long'].push -9999999.9
      end
      currentTweets['user'].push tweet.from_user
      currentTweets['ID'].push tweet.id
      currentTweets['timecode'].push tweet.created_at
    end
  end

  #Write out new set of tweets
  if currentNew != 0
    puts "Read #{currentNew} new tweets; total tweets in memory #{currentTweets['ID'].length}"
    File.open("tweetLog.txt", 'w') do |f|
      currentTweets['ID'].each_index do |i, x|
        f.write(currentTweets['species'][i] + '^' + currentTweets['count'][i].to_s + '^' + currentTweets['lat'][i].to_s + '^' + currentTweets['long'][i].to_s + '^' + currentTweets['ID'][i].to_s + '^' + currentTweets['description'][i] + '^' + currentTweets['user'][i] + '^' + currentTweets['timecode'][i].to_s + '^' + currentTweets['text'][i] + "\n")
      end
    end
  else
    puts "No new tweets read; exiting"
  end
end