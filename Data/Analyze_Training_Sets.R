load(file="Data/Training_Lacey_Classified.RData")
load(file="Data/Training_Lacey2_Classified.RData")
load(file="Data/Training_Linda_Classified.RData")
load(file="Data/Training_Linda_Classified2.RData")


df1 <- merge(lacey, linda, 
             by=c("author", "created", "title", 
                  "link", "post.text", "file"),
             all=T, suffixes = c(".la", ".li"))

df2 <- merge(lacey2, linda2, 
             by=c("author", "created", "title", 
                  "link", "post.text", "file"),
             all=T, suffixes = c(".la", ".li"))

df <- rbind(df1, df2)

df$suicidal.la[df$suicidal.la == ""] <- "0"

rm(df1, df2, lacey, linda, linda2, lacey2)

df$suicidal.la[is.na(df$suicidal.la)] <- "na"
df$suicidal.li[is.na(df$suicidal.li)] <- "na"

#with(df, table(suicidal.li, suicidal.la, 
#              useNA = "ifany"))
