library(rtweet)
library(ggplot2)
library(plotly)

setwd("D:/Users/witen/OneDrive/HUB/BIG DATA/Projekt_DB")

api_key <- "v7cnXT0xJJzQ3arakyBZWtHvF"
api_secret <-"lUZMcd75Oj3234wjfGsiu5bgu5fyD4XkzgdZYvm3ukfffgMtP4"
access_token <- "1167161106-NlIudZ6XYAPfwtfjhlFOXsnAhzgse9WQtLLne5y"
access_secret <- "LdB7J4IQjrop96lSd2RNNpHbdDN4yxz36yKRb6xT51d3c" 

twitter_token <- create_token(app="Project_Twitter_Covid", 
                              consumer_key = api_key, consumer_secret = api_secret,
                              access_token = access_token, access_secret = access_secret)

search_keywords <- "COVID OR koronavírus OR kovid OR világjárvány OR vakcina OR pandémia OR AstraZeneca OR Moderna OR Sinopharm OR Szputnyik OR Sputnik OR oltás OR oltakoz"

tweets <- search_tweets(q = search_keywords,
                        lang = "hu", n = 100000, include_rts = F, 
                        tweet_mode = "extended", token = twitter_token)

csv_name <- paste("twitter_", paste(gsub("-", "_", Sys.Date()), ".csv", sep=""), sep = "")
write.csv(flatten(tweets), csv_name, row.names = F)

# 
setwd("Projekt_DB/")

files <- list.files()
files <- files[grep("\\.csv", files)]


df <- read.csv(files[1])
base <- gsub("twitter|_|\\.csv", "", files[1])

df2 <- read.csv(files[2])
base <- gsub("twitter|_|\\.csv", "", files[2])

df <- dplyr::full_join(df,df2)

for (file in files[3:length(files)]){
  f <- read.csv(file)
  base <- gsub("twitter|_|\\.csv", "", file)
  df <- dplyr::full_join(df, f)
}

length(unique(df$text))


write.csv(df, "./all/2021_09_19_2022_04_09.csv")

df <- distinct(df, created_at,text, .keep_all = T)


df$DateTime <- strftime(df$created_at, "%Y-%m-%d %H:%M")
df$Date <- strftime(df$created_at, "%Y-%m-%d")
  
created <- table(df$Date)
c.df <- data.frame("date" = as.Date(names(created)), "count"=as.numeric(created))


x <- ggplot(c.df, aes(date, count)) +
  geom_line(colour="blue", size=1.2)+
  geom_hline(aes(yintercept = mean(count), linetype = "Átlag"), colour="red")+
  scale_linetype_manual(name = "", values = "dotted")+
  ggtitle("Tweetek száma naponként")+
  xlab("Dátum") + ylab("Tweetek száma")+
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 20),
        axis.title = element_text(size = 15, face = "bold"),
        axis.text = element_text(size=12))
ggplotly(x)

retweets <- aggregate(retweet_count ~ Date, df[c("Date", "retweet_count")], sum)
names(retweets) <- c("date", "count")
retweets$date <- as.Date(retweets$date)

x <- ggplot(retweets, aes(date, count)) +
  geom_line(colour="blue", size=1.2)+
  geom_hline(aes(yintercept = mean(count), linetype = "Átlag"), colour="red")+
  scale_linetype_manual(name = "", values = "dotted")+
  ggtitle("Retweetek száma naponként")+
  xlab("Dátum") + ylab("Retweetek száma")+
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 20),
        axis.title = element_text(size = 15, face = "bold"),
        axis.text = element_text(size=12))
ggplotly(x)


df$is_url <- as.numeric(!is.na(df$urls_expanded_url))
urls <- aggregate(is_url ~ Date, df[c("Date", "is_url")], sum)
names(urls) <- c("date", "count")
urls$Date <- as.Date(urls$Date)

x <- ggplot(urls, aes(date, count)) +
  geom_line(colour="blue", size=1.2)+
  geom_hline(aes(yintercept = mean(count), linetype = "Átlag"), colour="red")+
  scale_linetype_manual(name = "", values = "dotted")+
  ggtitle("Webes tartalommegosztás száma naponként")+
  xlab("Dátum") + ylab("Webes tartalom száma")+
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 20),
        axis.title = element_text(size = 15, face = "bold"),
        axis.text = element_text(size=12))
ggplotly(x)
