library(magrittr)
library(ggplot2)
library(plotly)
setwd("C:/Users/btk-sgt-006/Downloads")
df <- read.csv("databases/twitter_2021_09_26_2022_03_10.csv")

hist(df$retweet_count)

names(df)

days <- gsub(" .*", "", df$created_at)

hist(table(days) %>% sort(decreasing = T))

w_link <- df[!is.na(df$url),]

top100_w_link <- w_link[order(w_link$favorite_count, decreasing = T), ][1:100,]

write.csv(top100_w_link, "top100_w_link.csv")


t.df <- data.frame("date"= as.Date(unique(days)), "count"=as.numeric(table(days)))

t.df <- t.df[order(t.df$nap), ]


x <- ggplot(t.df, aes(date, count)) +
  geom_line(colour="blue", size=1.2)+
  geom_hline(aes(yintercept = mean(count), linetype = "Mean"), colour="red")+
  scale_linetype_manual(name = "", values = "dotted")+
  ggtitle("Tweetek száma naponként")+
  xlab("Dátum") + ylab("Tweetek száma")+
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
ggplotly(x)



# ?kezetmentes sz?vegek
# legt?bb like-ot kapott linkes tweetek
# emojik ?rtelmez?se
# gyakoris?g id?ben
# sentiment id?ben
