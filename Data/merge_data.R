#Create the dataset

#### Clean up the data

#setwd("/Users/lindagai/Documents/classes/2nd year/Data Science/Wk8_final/")

#classified has the june posts with the SI classification.
load(file="Data/Classified_Posts/June_Posts_Classified.RData")
#4841 posts
#17200 comments

#load pretest data
#749 observations
load(file="Data/Classified_Posts/June_Posts_Hand_Classified.RData")

#95 observations
load(file="Data/Pre_Test/Pretest_Cleaned_Data.RData")

#Create training sets using:
# hand-classified data - get the pretest data at some point
#   (posts not from r/dep)
#source("Analyze_Training_Sets.R")
#   (500 posts and comments from r/dep)

#53 suicidal posts
#sui.text.dep <- df %>%filter(suicidal.la==1 | suicidal.li==1)

#Test for whether any posts were labeled as "na" by both Lacey and Linda
test <-df %>% filter(suicidal.la=="na") %>%
  filter(suicidal.li=="na")
#0, which is what we expect

#42 suicidal posts--used to be 43?
sui.text.dep <- df %>%
  filter(sui==1)

# posts identified by the algorithm from june
sui.post.june <- post.data[which(post.data$class==TRUE),]
sui.comm.june <- comm.data[which(comm.data$class==TRUE),]

# Non-suicide:
# hand-classified posts and comments that were not marked as suicidal.

#707 posts
sui.text.not.dep <-df %>%
  filter(sui==0)

#Put them together in a dataframe
text1 <-sui.text.not.dep  %>%
  select(author, created, post.text) %>%
  mutate(subreddit_id ='depression', suicidal="not suicidal") %>%
  rename(text=post.text)

#385 suicidal comments
text2 <- sui.post.june %>%
  select(author, created_utc, selftext, subreddit_id) %>%
  rename(created=created_utc,text=selftext) %>%
  mutate(suicidal="suicidal") 

#Pretest data - 42 suicidal posts
text3 <- sui.text.dep %>%
  select(author, created, post.text) %>%
  mutate(subreddit_id ='depression', suicidal="suicidal") %>%
  rename(text=post.text)

#Check this one later to make sure it's correct
#Note that the subreddits have been translated to words
#Dates are also ints and not in same format as others
sui.vector = rep(NA,length(pretest$suicidal))
for (i in 1:length(pretest$suicidal)){
  if (pretest$suicidal[i]==TRUE | pretest$suicidal.past[i]==TRUE){
    sui.vector[i]="suicidal"
  } else {
    sui.vector[i]="not suicidal"
  }
}

text4 <- pretest %>%
  select(author, date, text, subreddit)

#95 obs
text4<- cbind(text4, sui.vector) %>%
  rename(suicidal=sui.vector,created=date, subreddit_id=subreddit)

#162 observations
text5 <- sui.comm.june %>%
  select(author, created_utc, body, subreddit_id) %>%
  rename(created=created_utc,text=body) %>%
  mutate(suicidal="suicidal") 

#complete <-rbind(text1,text2,text3,text4) #624
#complete <-rbind(text1,text3,text4) 
#844 variables = 707 + 42 + 95 -- looks right

complete <-rbind(text1,text2,text3,text4,text5) #1391

complete$subreddit_id <-gsub('t5_2qqqf','depression', complete$subreddit_id)

#Uniqueness of authors - not sure if this is useful
length(unique(complete$author)) #561
repeats <- complete %>%
  group_by(author) %>%
  filter(n()>1) 

sort.rep.authors <- sort(table(repeats$author),decreasing=T)

#Suicidal 
nrow(complete %>% filter(suicidal=='suicidal')) #611
nrow(complete %>% filter(suicidal=='not suicidal')) #759

#Get rid of whitespace
cleaner <-gsub("[\\]u2019", "'", complete$text)
cleaner <-gsub("[\\]n", "", cleaner)
cleaner <-gsub("\\n", "", cleaner)
complete$text <- cleaner

#Get rid of deleted posts
n<-length(complete$text)
for (i in 1:n) {
  if (complete$text[i]=="" | is.na(complete$text[i])){
    complete<-complete[-i,] 
    i = i-1 
  }
}

#Get rid of posts that don't contain text
is.letter <- function(x) grepl("[[:alpha:]]", x)

for (i in 1:n) {
  if (!is.letter(complete$text[i])){
    complete<-complete[-i,] 
    i = i-1 
  }
}

#Add row number
complete <- complete %>% 
  mutate(post.id = row_number())

#Get rid of any unnecessary objects
rm(list=setdiff(ls(), "complete"))

#Write complete data to file
save(complete,file = "complete.RData")
