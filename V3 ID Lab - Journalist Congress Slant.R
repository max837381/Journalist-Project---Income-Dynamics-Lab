# Load necessary packages
rm(list = ls())
gc()
set.seed(0)
setwd("/Users/max/Documents/UCSC/Summer 2022/Journalist Project - Income Dynamics Lab/")
#install.packages("pacman")
# Pacman package installs and updates packages
library(pacman)
p_load(gamlr,tm, textir, wordcloud2, tidyverse, usethis, Matrix)


data(congress109)
dim(congress109Counts)
congress109Counts[c("Barack Obama", "John Boehner"), 995:998]


##Memory issues??? cant merge: says vector limit reached
# Increase memory usage by including: R_MAX_VSIZE=100Gb
#usethis::edit_r_environ()


# This contains speaker id | phrase (bigram) | count
txt_byspeaker <- "hein-daily/byspeaker_2gram_114.txt"
byspeaker_original <- read.table(txt_byspeaker,sep="|",header=T)


# Limit size (takes too long to compute for testing; can be changed later)
# First 50,000 observations
byspeaker <- byspeaker_original[sample(nrow(byspeaker_original),size=50000),]

# Long to wide reshape
#byspeaker_wide <- reshape(byspeaker, idvar = "speakerid", timevar = "phrase",  direction = "wide")
#Matrix <- sparseMatrix(i = as.numeric(byspeaker$speakerid), j = as.numeric(byspeaker$phrase), x = byspeaker$count, dims = c(nlevels(byspeaker$speakerid, nlevels(byspeaker$phrase)), dimnames = list(id = levels(byspeaker$speakerid),site = levels(byspeaker$phrase)))

test <- byspeaker %>% pivot_wider(names_from = phrase, values_from = count)


# Drop columns or bigrams with a lot of NAs (greater than 90% of observations)
# test <- test[lapply(test, function(x) mean(is.na(x))) < 0.90]



# Load speakermap files
speakermap_file <- "/Users/max/Documents/UCSC/Summer 2022/Journalist Project - Income Dynamics Lab/hein-daily/114_SpeakerMap.txt"
speakermap <- read.table(speakermap_file,sep="|",header=T)


# concentanate the names
speakermap$name <- paste(speakermap$firstname, speakermap$lastname)

# Remove duplicate names
speakermap <- speakermap[!duplicated(speakermap$name), ]


# Matching for now instead for name and party
test$party = speakermap$party[match(test$speakerid, speakermap$speakerid)]
test$name = speakermap$name[match(test$speakerid, speakermap$speakerid)]

# Moving columns around
test <- test %>% relocate(party, .before = `speakerid`)
test <- test %>% relocate(name, .before = party)

# MERGING CODE
#jointdataset <- merge(test, byspeaker, by = 'speakerid', all.x= TRUE)

# Doesnt work on all files (vector memory limit reached)
#merged_speaker_file <- inner_join(byspeaker, speakermap, by = c("speakerid"))

# Check for who is independent
test[which(test$party == "I"), ]

# Bernie Sanders and Angus King both seem to be Democrat leaning thus we will change their values to D
test$party[test$name == "BERNARD SANDERS"] <-"D"
test$party[test$name == "ANGUS KING"] <-"D"

# You could do this with one line but since with more data we might also encounter some more R-leaning this is a better way to do it


# Convert party to factor
test$party <- factor(test$party)

## BELOW CODE COULD BE INCLUDED LATER IF NECESSARY
# 
# # Phrase partisanship
# ## Positive numbers correspond to Republican phrases
# ## Negative numbers correspond to Democrat phrases
# 
# # contains outcome/slant data?
# txt_partisanship1 <- "phrase_partisanship/partisan_phrases_114.txt"
# phrase_partisanship1 <- read.table(txt_partisanship1,sep="|",header=T)
# 
# txt_partisanship2 <- "phrase_partisanship/partisan_phrases_113.txt"
# phrase_partisanship2 <- read.table(txt_partisanship2,sep="|",header=T)
# 
# 
# phrase_partisanship <- rbind(phrase_partisanship1,phrase_partisanship2,phrase_partisanship3,phrase_partisanship4)
# 
# # Bigrams master list
# #txt_master_list <- "/Users/max/Documents/UCSC/Summer 2022/Journalist Project - Income Dynamics Lab/vocabulary/master_list.txt"
# #bigrams_master_list <- read.table(txt_master_list,sep="|",header=T)
# 
# 
# 
# # Merge bigram by party and slant data
# data_test <- merge(df, phrase_partisanship1, by=c("phrase"))
# data_test[1:3,]
# #data_test <- data_test[,-c(4)]
# 
# # reshaping
# data_wide<- reshape(data=df,idvar="name",
#                        v.names = c("count", "party"),
#                        timevar = "phrase",
#                        direction="wide")
# 
# data_wide2 = spread(df, phrase, count)
# 
# # Row, Column
# 


# Setting up the LASSO regression

# Change Y so it is 0 or 1 (in this case I will use 1 as Republican and 0 for not Republican (this will che changed of extended upon later))
# 
# df$party[df$party=="R"] <- 1
# df$party[df$party!="R"] <- 0



#replace NA with 0
test <- test %>% replace(is.na(.), 0)

y <- test$party
x <- test[,-c(2,3)]


sparse_matrix <- Matrix(as.matrix(x), sparse = TRUE)

# Warning message: In storage.mode(from) <- "double" : NAs introduced by coercion
# I THINK THIS WARNING MESSAGE CAN BE IGNORED??


#sparse_matrix <- sparse_matrix[,-1]
rm(test)
rm(byspeaker)
rm(congress109Counts)
rm(congress109Ideology)
rm(speakermap)
#x <- model.matrix(~ ., data=x)[,-1]


lassoslant <- cv.gamlr(x, y)
B <- coef(lassoslant, select = "min")[-1, ]
sort(round(B[B != 0], 4)) # nonzero coefficients
plot(lassoslant)


x_prop <- x/rowSums(x)
lassoslant_prop <- cv.gamlr(x_prop, y)

B <- coef(lassoslant_prop$gamlr)[-1, ]

# Low repshare (Dems)
names(sort(B)[1:10])

# High repshare (Repubs)
names(sort(-B)[1:10])






# THIS PART OF THE CODE DOES NOR WORK YET
# I attempted to use our model to predict the slant of speaker data


speaker_txt <- "/Users/max/Documents/UCSC/Summer 2022/Journalist Project - Income Dynamics Lab/hein-daily/byspeaker_2gram_114.txt"

speaker <- read.table(speaker_txt,sep="|",header=T)
data_speaker <- merge(speaker, phrase_partisanship, by=c("phrase"))
#data_speaker_test <- head(data.frame(data_speaker),38522)
data_speaker_test <- data_speaker_test[,-c(4)]
x_speaker <- model.matrix(~ ., data=data_speaker_test)[,-1]
x_speaker <- head(model.matrix(~ ., data=data_speaker_test)[,-1],94032202)
pred_speaker_slant <- predict(lassoslant, x_speaker, type="response")

dim(data_speaker)



dim(x_speaker)

merge_speaker <- rbind(data_test, data_speaker)

data_test <- merge(data_test, data_speaker, by=c("phrase"))

results<-merge(x=data_test,y=data_speaker,by=c("phrase"),all.y=TRUE)
df = data_test %>% left_join(data_speaker,by="phrase")



# Prediction
#pred <- predict(lassoslant, newdata = x_speaker)







