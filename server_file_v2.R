
# easy loading of packages
library(pacman)
p_load(tidyverse, data.table, tm, quanteda, tokenizers, tidytext, tictoc, gamlr, usethis, Matrix, renv, reactable)

# No scientific notation
options(scipen = 100)

# setting up the working environments
#setwd("/Users/max/Desktop/Journalist Project - Income Dynamics Lab")

# Initialize setting up package dependencies
#renv::init()


# takes a snapshot of package dependencies
renv::snapshot()
tic("total")

# Generate R file from this R notebook
# knitr::purl("Current_Journalist_R_Notebook.Rmd")

#IF PLACED IN PROJECT THEN NO FILE PATHS NEEDED

# Dummies 

# full mypath = "/Users/max/Desktop/Journalist Project - Income Dynamics Lab/"
mypath = paste(getwd(), "/hein-daily", sep = "")



# Make y variable a factor or not (Makes no difference)
lasso_y_as_factor = 1

# Speaker or speech level
speaker_level = 1

# Number of files
num_files = 2

# Word Cutoff for the Congressional Speech data i.e. min. number of words in each speech
word_cutoff = 250

# Number of observations used for congress data (needs to be bigger than 3000)
congress_observations = 4000

# Cross_validation?
cross_validated = 1
nfolds_cv = 5

# Number of wapo articles analyzed
wapo_article_size = 10000


# Load in Congress data

### Loading in the relevant congressional speech files for creating the X matrix for the LASSO regression

# The wapo articles range from 2005 to 2015 thus we will need to


tic("load speech file")
# Earliest speech file needed
earliest_year = 1999

earliest_speech_file <- ((earliest_year - 1981)/2) + 97


cat("The earliest date for the wapo articles is", earliest_speech_file)

# Last speech file needed
latest_year = 2015

latest_speech_file <- ((latest_year - 1981)/2) + 97

#num_files = (latest_speech_file - earliest_speech_file) + 1


cat("The latest date for the wapo articles is", latest_speech_file)


# Loading in the latest congressional speech file from 109 to 114 (I created a folder which contains these files)
# FUTURE UPDATE: code which years and it will automatically select the relevant files


txt_files_ls <- tail(list.files(path=mypath, pattern="*.txt"),num_files)

cat("The files used are ", txt_files_ls)

# Read the files in, assuming comma separator
txt_files_df <- lapply(txt_files_ls, function(x) {read.table(file = paste(mypath,x, sep = "/"), header = TRUE, sep ="|", quote = "", fill = TRUE)})
# Combine them

df <- do.call("rbind", lapply(txt_files_df, as.data.frame)) 

df <- df[sample(nrow(df), 3000),]

# Single file approach
# df <- read.table("/Users/max/Desktop/Journalist Project - Income Dynamics Lab/hein-daily/speeches_114.txt", header=TRUE, sep="|", quote = "", fill = TRUE)

toc()


# Initial Analysis

### Analyze the dataset of speech files


tic("Speech data analysis")
# find any missing observations
sum(is.na(df))

# dimensions of the dataframe
dim(df)

# Find out the number of words of each speech
df$nwords <- str_count(df$speech, "\\w+")
#df$nwords <- sapply(df$speech, function(x) length(unlist(strsplit(as.character(x), "\\W+"))))


cat("The number of speeches with NA as the value is ", sum(is.na(df$nwords)))
cat("The number of speeches with 0 words, thus empty is ", length(df$nwords[df$nwords==0]))
as.data.frame(table(cut(df$nwords,breaks=seq(0,2000,by=50))))
summary(df$nwords)
toc()


#Creating a frequency plot


# p <- ggplot(df[df$nwords<250,], aes(x = nwords)) +
#   geom_freqpoly(bins=50, color = "navyblue") +
#   labs(
#     title = "Frequency of Congressional Speech length",
#     x = "Number of Words",
#     y = "Observations"
#   )
# rect <- data.frame(xmin=20, xmax=30, ymin=-Inf, ymax=Inf)
# pp <- p + geom_rect(data=rect, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax), color=NA, alpha=0.2, inherit.aes = FALSE)
# pp + scale_x_continuous(breaks = seq(0, 100, by = 10))
# 
# jpeg('rplot.jpg')
# plot(p)
# dev.off()
#From the graph we should consider limiting our observations to approx. 10-20 number of words to cut out anything that cannot be considered a speech. This can be adjusted based on our results vs Stanford study.

#A lot of these observations involve: "and now let's give the floor to the gentleman from Florida.. etc." These observations do not contain much political meaning or context and we should thus consider limiting our observations as such


# Lets take the 1st quartile as an example (this is something that could be changed)
#df <- df[df$nwords>11,]
df <- df[df$nwords>word_cutoff,]

# Keep number of words as a separate vector when needed
nwords <- df$nwords

# Subset columns only speech_id and speeches
df <- df[c(1,2)]

# Sampling code that may be useful but will not be executed in this file as of the current version
#df <- df[sample(nrow(df),size=congress_observations),]


# Congress Speech Bigram Conversion Pt. 1

#These steps are very close to the Stanford/Taddy study and the results obtained are similar when comparing the output files.


tic("bigram conversion - until tokens")
# rename columns in order to put them into a corpus object
colnames(df)[colnames(df) == 'speech_id'] <- "doc_id"
colnames(df)[colnames(df) == 'speech'] <- "text"

# (ii) removing apostrophes and replacing commas and semicolons with periods
## removing apostrophes
df$text <- gsub("'", '', df$text)

# replacing commas and semicolons with periods
df$text <- gsub(",", '.', df$text)
df$text <- gsub(":", '.', df$text)

# (iii) replacing repeated white space characters with a single space (if necessary)
df$text <- str_squish(df$text)

# (iv) removing punctuation—hyphens, periods, and asterisks—that separate the article’s demarcation from the actual article
df$text <- gsub('"', '', df$text)
df$text <- gsub('.', '', df$text, fixed = TRUE)
df$text <- gsub('*', '', df$text)
df$text <- gsub('-', '', df$text)

# STEP V removing white spaces at the beginning and end of the speeches
# removes leading and trailing white spaces from the character vectors a.k.a the speeches
df <- df %>% 
  mutate(across(where(is.character), str_trim))

corpus <- corpus(df)
tokenz <- tokenizers::tokenize_words(corpus, lowercase = TRUE,) %>%
  tokens(what = "word",remove_punct = TRUE, remove_symbols = TRUE, remove_numbers = FALSE, remove_url = TRUE, remove_separators = TRUE, split_hyphens = TRUE, include_docvars = TRUE, padding = TRUE, verbose = quanteda_options("verbose"), )

toc()


# Congress Speech Bigram Conversion Pt. 2


tic("bigram conversion - finished")
tokenz[3]
tokenz <- tokens_remove(tokenz, pattern = stopwords("en"))
tokenz[3]
tokenz <- tokens_wordstem(tokenz, language = "en")
tokenz[3]
toks_ngram <- tokens_ngrams(tokenz, n = 2, concatenator = " ")

toks_dfm <- dfm(toks_ngram)

DF <- tidytext::tidy(toks_dfm)
colnames(DF)[colnames(DF) == 'document'] <- "speech_id"

txt_files_ls <- tail(list.files(path=mypath, pattern="SpeakerMap.txt"), num_files)

cat("The files used are ", txt_files_ls)

# Read the files in, assuming comma separator
txt_files_df <- lapply(txt_files_ls, function(x) {read.table(file = paste(mypath,x, sep = "/"), header = TRUE, sep ="|")})
# Combine them

speaker_map <- do.call("rbind", lapply(txt_files_df, as.data.frame)) 

# speaker_map <- read.csv("/Users/max/Desktop/Journalist Project - Income Dynamics Lab/hein-daily/114_SpeakerMap.txt", header = TRUE, sep = "|")
DF <-merge(x=DF,y=speaker_map,by="speech_id",all.x=TRUE)
#DF <- DF[c(1:4)]

x <- DF
# x <- DF %>% 
#   group_by(speakerid, term) %>%
#   summarise(Frequency = sum(count))

x <- x[complete.cases(x),]
head(x)

toc()




# This could be run when wanting to export the files or comparing the Stanford study bigrams to the bigrams created by this file


# bigrams_file <- read.table("/Users/max/Desktop/Journalist Project - Income Dynamics Lab/hein-daily/byspeaker_2gram_114.txt", header=TRUE, sep="|", quote = "", fill = TRUE)
# 
# # Rename columns and delete irrelevant columns
# write.csv(x, file ="/Users/max/Desktop/Journalist Project - Income Dynamics Lab/best_bigram_similarity_file.csv")
# 
# toc()


# Coding our dependent variable

### Here we will code that R = 1 and D = 0.

#Changed the code to create the x matrix for speechid instead of speakerid



byspeaker <- x

# Merge with speakermap files in terms
#byspeaker <- byspeaker[c(2,3,4)]
colnames(byspeaker)[colnames(byspeaker) == 'term'] <- "phrase"
colnames(byspeaker)[colnames(byspeaker) == 'Frequency'] <- "count"
#byspeaker <- byspeaker[complete.cases(byspeaker), ]

# create sparse matrix
#byspeaker$speakerid <- factor(byspeaker$speakerid)
#byspeaker$speech_id <- factor(byspeaker$speech_id)
byspeaker$phrase <- factor(byspeaker$phrase)

# byspeaker$speech_id <- factor(byspeaker$speech_id)

str(byspeaker)
dim(byspeaker)



#The code chunk above shows that we have successfully created a factor with more levels by using speech_id instead of speaker id

# Creating Sparse Matrix


# X <- sparseMatrix(i = as.numeric(byspeaker$speakerid), j = as.numeric(byspeaker$phrase), x = byspeaker$count, dims = c(nlevels(byspeaker$speakerid), nlevels(byspeaker$phrase)), dimnames = list(id=levels(byspeaker$speakerid), phrase=levels(byspeaker$phrase)))
speakermap <- speaker_map

byspeaker$unique_speech_id <- make.unique(as.character(byspeaker$speech_id) ,sep = ".")
byspeaker <- byspeaker[order(byspeaker$unique_speech_id),]
byspeaker$unique_speech_id <- factor(byspeaker$unique_speech_id)


X <- sparseMatrix(i = as.numeric(byspeaker$unique_speech_id), j = as.numeric(byspeaker$phrase), x = byspeaker$count, dims = c(nlevels(byspeaker$unique_speech_id), nlevels(byspeaker$phrase)), dimnames = list(id=levels(byspeaker$unique_speech_id), phrase=levels(byspeaker$phrase)))


print(object.size(X),units="auto")
dim(X)
matrixplot <- image(X)

matrixplot

# Zoomed in version
image(X[1:400,1:400])


# byspeaker$paste <- factor(paste(byspeaker$speech_id, byspeaker$phrase))
# X_test2 <- sparseMatrix(i = as.numeric(byspeaker$paste), j = as.numeric(byspeaker$phrase), x = byspeaker$count, dims = c(nlevels(byspeaker$paste), nlevels(byspeaker$phrase)), dimnames = list(id=levels(byspeaker$paste), phrase=levels(byspeaker$phrase)))
# 


# check that it worked
byspeaker[1:5,]

X[1,as.numeric(byspeaker$phrase)[1:5]]
#rm(byspeaker)


# speakermap <- read.table("hein-daily/114_SpeakerMap.txt", sep="|", header=T)


# speakermap <- speaker_map
# 
# 
# 
# speakermap$name <- paste(speakermap$firstname, speakermap$lastname) # one name
# speakermap <- speakermap[!duplicated(speakermap$speakerid),c("speakerid","party", "name")] # drop irrelevant cols
# speakermap <- speakermap[order(speakermap[,1]),] # sort by id

# drop ids not in X
drop_these_ids <- as.integer(setdiff(as.character(factor(byspeaker$unique_speech_id)),row.names(X)))
byspeaker <- byspeaker[!(byspeaker$speakerid %in% drop_these_ids),]

# Merge to have a speaker id for each speech_id

# check that ids in X and speakermap line up
if (sum(!(row.names(X)==as.character(factor(byspeaker$unique_speech_id)))) != 0) { print("Recheck code: ids are not aligned.")}



# Bernie Sanders and Angus King both seem to be Democrat leaning thus we will change their values to D
byspeaker$party[byspeaker$name == "BERNARD SANDERS"] <-"D"
byspeaker$party[byspeaker$name == "ANGUS KING"] <-"D"
byspeaker$party[byspeaker$name == "GREGORIO SABLAN"] <-"D"
# This can be checked later to see if there are any other congressmen that need to be recoded in terms of their political party
byspeaker$party[byspeaker$party == "I"] <-"D"
#speakermap$party <- factor(speakermap$party)
table(byspeaker$party)

# lasso with raw counts
if (lasso_y_as_factor == 0) {
  cat(" ")
  cat(" ")
  cat("Party variable will be converted to factor")
  cat(" ")
  cat(" ")
  byspeaker$party <- factor(byspeaker$party)
  head(byspeaker$party)
} else {
  byspeaker$party <- ifelse(byspeaker$party == "R", 1,0)
  cat(" ")
  cat(" ")
  cat("Manually coded for R = 1 and D = 0")
  cat(" ")
  cat(" ")
  head(byspeaker$party)
}

str(byspeaker)


# Cross-Validated LASSO Regression


# y <- speakermap$party
y <- byspeaker$party

if (cross_validated==1) {
  lassoslant <- cv.gamlr(X,y, nfold = nfolds_cv, verb = TRUE , select="1se")
  plot(lassoslant)
  B <- coef(lassoslant, select="1se")[-1, ]
  cat("Using cv.gamlr function with cross-validation")
} else {
  lassoslant <- gamlr(X, y) # use AICc for speed
  plot(lassoslant)
  B <- coef(lassoslant)[-1, ]
  cat("Using gamlr function with AICc (no cross-validation)")
}
#lassoslant <- gamlr(X, y) # use AICc for speed
#lassoslant <- cv.gamlr(X,y, nfold = nfolds_cv, verb = TRUE , select="1se")
plot(lassoslant)

B <- coef(lassoslant, select="1se")[-1, ]
head(sort(round(B[B != 0], 4))) # nonzero coefficients
tail(sort(round(B[B != 0], 4)))
coefficients_lasso2 <- data.frame(as.list(sort(round(B[B != 0], 4)))) # nonzero coefficients
#write.csv(coefficients_lasso2, file ="/Users/max/Desktop/Journalist Project - Income Dynamics Lab/lasso_coefficients.csv")
names(sort(B)[1:10]) # Low repshare (Dems)
names(sort(-B)[1:10]) # High repshare (Repubs)

# lasso with proportions
x_prop <- X/rowSums(X)
lassoslant_prop <- gamlr(x_prop, y)
B_prop <- coef(lassoslant_prop)[-1, ]
sort(round(B_prop[B_prop != 0], 4))
names(sort(B_prop)[1:10]) # Low repshare (Dems)
names(sort(-B_prop)[1:10]) # High repshare (Repubs)

# plot AICc curves
# ll <- log(lassoslant$lambda) # the sequence of lambdas
# ll <- log(lassoslant$lambda.1se) # the sequence of lambdas
# # plot(ll, AICc(lassoslant)/length(y), xlab = "log lambda", ylab = "AICc/n", pch = 21, bg = "orange")
# plot(ll, AICc(lassoslant$lambda.1se)/length(y), xlab = "log lambda", ylab = "AICc/n", pch = 21, bg = "orange")
# abline(v = ll[which.min(AICc(lassoslant))], col = "orange", lty = 3)
# abline(v = ll[which.min(AICc(lassoslant_prop))], col = "black", lty = 3)
# points(ll, AICc(lassoslant_prop)/length(y), pch = 21, bg = "black")
# legend("topright", bty = "n", fill = c("black", "orange"), legend = c("lassoslant", "lassoslant_prop"))



# Prediction

coefficients_lasso <- pivot_longer(coefficients_lasso2, cols = everything(), names_to = "phrase",  values_to = "coefficient")
coefficients_lasso$phrase <- gsub('X', '', coefficients_lasso$phrase)
coefficients_lasso$phrase <- gsub('X', '', coefficients_lasso$phrase)
coefficients_lasso$phrase <- gsub('[[:punct:] ]+',' ',coefficients_lasso$phrase)
coefficients_lasso$phrase <- trimws(coefficients_lasso$phrase, which = c("both"))

# number of coefficients
length(coefficients_lasso)

# writes to folder or getwd() directory
write.csv(coefficients_lasso, "bigram_coefficients.csv")