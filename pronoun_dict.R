
library(dplyr)

### Read in the pronoun lexicon
words <- readLines("pronouns.txt")
words <- gsub("\t","",words)
word.list <- list()

for(i in words){
  if(grepl("\\[", i)){
    category <- sub("\\[","",i)
    category <- sub("\\]:","",category)
    category <- sub(" ","_",category)
    word.list[category] <- ""
  } else word.list[[category]] <- append(word.list[[category]], i)
}

word.list <- lapply(word.list, function(x) x[-1])

#Scratch
#get.counts <- function(str,word.list){
 # first <- pmatch(str, word.list[,1])
 # second <- pmatch(str, word.list[,2])  
#  third <- pmatch(str, word.list[,3])  
#  return(c(first,sec,third)) 
#}

