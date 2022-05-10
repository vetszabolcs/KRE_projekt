library(ggplot2)
library(plotly)
library(htmlwidgets)
library(rlang) # {{}} hasznalata valtozokra torteno hivatkozas eseten (plotfun)

setwd("D:/Users/witen/OneDrive/HUB/BIG DATA/Projekt_DB/all/")

df <- read.csv("2021_09_19_2022_04_09.csv")

df <- distinct(df, created_at,text, .keep_all = T)


df$DateTime <- strftime(df$created_at, "%Y-%m-%d %H:%M")
df$Date <- strftime(df$created_at, "%Y-%m-%d")

created <- table(df$Date)
c.df <- data.frame("date" = as.Date(names(created)), "count"=as.numeric(created))

plotfun <- function(data, date, count,
                    main="Tweetek száma naponként",
                    xlab="Dátum", ylab="Tweetek száma",
                    color="blue", file){
  x <- ggplot(data, aes( {{date}}, {{count}} )) +
    geom_line(colour=color, size=1.2)+
    geom_hline(aes(yintercept = mean( {{count}} ), linetype = "Átlag"), colour="red")+
    scale_linetype_manual(name = "", values = "dotted")+
    ggtitle(main)+
    xlab(xlab) + ylab(ylab)+
    theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 20),
          axis.title = element_text(size = 15, face = "bold"),
          axis.text = element_text(size=12))
  
  if (missing(file)) {
    ggplotly(x)
  }else {
    if (!grepl("\\.html", file)){
      file <- paste(file, ".html", sep="")
      warning("Added html extension")
    }
    saveWidget(ggplotly(x), file = file)
    print(paste("Plot saved as ", getwd(), "/", file, "", sep=""))
    csv <- gsub("(.*\\.)(.*)", "\\1csv", file)
    write.csv(data, csv)
    print(paste("Data saved as ", getwd(), "/", csv, "", sep=""))
    ggplotly(x)
  }
}

plotfun(c.df, date, count, file="tweet_count")


retweets <- aggregate(retweet_count ~ Date, df[c("Date", "retweet_count")], sum)
names(retweets) <- c("date", "count")
retweets$date <- as.Date(retweets$date)

plotfun(retweets, date, count, file = "retweet_count",
        color = "cyan3",
        main = "Retweetek száma naponként",
        ylab = "Retweetek száma")



df$is_url <- as.numeric(!is.na(df$urls_expanded_url))
urls <- aggregate(is_url ~ Date, df[c("Date", "is_url")], sum)
names(urls) <- c("date", "count")
urls$date <- as.Date(urls$date)

plotfun(urls, date, count, file = "urls_count",
        color = "deepskyblue4",
        main = "Webes tartalommegosztások száma naponként",
        ylab = "Webes tartalommegosztások száma")

