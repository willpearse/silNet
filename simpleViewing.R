#Loading the silNet data file into R

#Data
data <- read.csv("tweetLog.txt", sep="^", header=FALSE)
names(data) <- c("species", "count", "lat", "long", "ID", "description", "user", "timecode", "tweet")

#Select on GPS-enabled tweets and plot
# - something weird's going on with some (longs of 0...)
geo.data <- data[data$lat > 0 & data$long < 0,]
with(geo.data, plot(lat~long, pch=20))

#Proportion of GPS-tweets:
(nrow(geo.data) / nrow(data)) * 100

#Rank curve of users/contributers
# - why is there a blank user?
# - also - URG!
user.freq <- table(data$user)[-1]
user.freq <- sort(user.freq, decreasing=TRUE)
with(data, barplot(user.freq))