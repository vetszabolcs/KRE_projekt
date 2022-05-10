library(dplyr)
library(stringi)
setwd("D:/Users/witen/Desktop")

df <- xlsx::read.xlsx2("ezeket.xlsx", sheetIndex = 1, header = F)
names(df) <- c("index", "text")
df$text <- stri_trim(df$text)

df$text[df$text == ""] <- NA
df$index[df$index == ""] <- NA
df <- df[!is.na(df$text),]

is.na(df$text) %>% any()

for (i in 1:nrow(df)){
  if (is.na(df[i, "index"])){
    df[i,"index"] = df[i-1,"index"]
  }
}

any(is.na(df$index))
df$index <- as.integer(df$index)




grouped <- df %>%
  group_by(index) %>%
  summarise(concat = paste(text, collapse = "\n")) %>% 
  arrange(index) %>% arrange(index)

View(grouped[,"concat"])

xlsx::write.xlsx(grouped[,"concat"], "4000_eredeti.xlsx")

uni <- as.data.frame(unique(grouped$concat))
xlsx::write.xlsx(uni, "4000_egyedi.xlsx")



############################
library(dplyr)

reindex <- function(df, index="index"){
  data <- df
  for (i in 1:nrow(data)){
    if (is.na(data[i, index])){
      data[i,index] = data[i-1,index]
    }
  }
  return(data)
}

concat_on_index <- function(df, index="index", text="text"){
  data <- df %>%
          group_by(index) %>%
          summarise(concat = paste(text, collapse = "\n")) %>% 
          as.data.frame()
  
  data[,index] <- as.integer(data[,index])
  data <- arrange(data, index)
  return(data)
}

setwd("D:/Users/witen/Desktop/")
df <- xlsx::read.xlsx("corrected.xlsx", 1)

df <- reindex(df) %>% concat_on_index(.)
xlsx::write.xlsx(df, "corrected_R.xlsx", row.names = F)


