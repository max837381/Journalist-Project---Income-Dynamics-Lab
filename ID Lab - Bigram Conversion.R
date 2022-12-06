rm(list = ls())
#setwd('/Users/max/Documents/UCSC/Summer 2022/Journalist Project - Income Dynamics Lab')
Sys.setenv(RETICULATE_PYTHON = "/Users/max/Documents/UCSC/Summer 2022/(Local) Journalist Project - Income Dynamics Lab/my_env/bin/python")
library(pacman)
p_load(tidyverse, tm, data.table, reticulate, quanteda, wordcloud, readr)
fileName <- "/Users/max/Documents/UCSC/Summer 2022/(Local) Journalist Project - Income Dynamics Lab/stop_snowball_tartarus.txt"

# Load as variable (article = variable)
stop <- readChar(fileName, file.info(fileName)$size)

stop2 <- gsub(".*\n ", "", stop)

stop2 <- str_split(stop, '\n', simplify = TRUE)[,2]

stopwords <- stopwords()

#wapo <- fread('/Users/max/Documents/UCSC/Summer 2022/(Local) Journalist Project - Income Dynamics Lab/wapo_articles.csv')
first_article <- read.table("/Users/max/Documents/UCSC/Summer 2022/(Local) Journalist Project - Income Dynamics Lab/hein-daily/speeches_114.txt", header=TRUE, sep="|", quote = "", fill = TRUE)
#wapo <- "/Users/max/Documents/UCSC/Summer 2022/(Local) Journalist Project - Income Dynamics Lab/hein-daily/speeches_114.txt"
#first_article <- read.table(wapo,sep="|",header=T, fill=FALSE, quote="")
#first_article <- read_file("/Users/max/Documents/UCSC/Summer 2022/(Local) Journalist Project - Income Dynamics Lab/hein-daily/speeches_114.txt")

#first_article <- wapo[1,5]

# This code will follow section 2.2 from the Matthew Gentzkow, Jesse M. Shapiro, Matt Taddy codebook.

##### CLEANING STEPS

# (i) Remove non-article text (in the wapo.csv there seems to be very little)
## I noticed that each article starts with '1: ' Thus I removed that from the data
first_article <- gsub("1: ","", first_article)

# (ii) removing apostrophes and replacing commas and semicolons with periods
## removing apostrophes
first_article <- gsub("'", '', first_article)

# replacing commas and semicolons with periods
first_article <- gsub(",", '.', first_article)
first_article <- gsub(":", '.', first_article)

# (iii) replacing repeated white space characters with a single space (if necessary)
first_article <- str_squish(first_article)

# Further cleanup that I saw was needed
first_article <- gsub('"', '', first_article)
first_article <- gsub('-', '', first_article)

# (iv) removing punctuation—hyphens, periods, and asterisks—that separate the article’s demarcation from the actual article
## FOR THE WAPO ARTICLES WE CAN SKIP THIS THIS STEP IT SEEMS

##### PROCESSING STEPS

# First, the number of characters and space-delimited words are computed.
## In a future version these could be saved as separate columns in the wapo.csv file in the corresponding row
nchar(first_article)
length(words(first_article))

# str_count produces the wrong result in this case, not sure why (it counts 4 more words)
# str_count(first_article, "\\w+") 

# Second, the speech is coerced to lowercase.
first_article <- tolower(first_article)

# Third, the speech is broken into separate words, treating all non-alphanumeric characters as delimiters.

first_article <- strsplit(gsub("[^[:alnum:] ]", "", first_article), " +")[[1]]

# Fourth, general English-language stopwords are removed (using the same list from the snowball website)
first_article <- removeWords(first_article, stopwords('english'))

# Remove empty character strings
first_article <- first_article[first_article != ""]

file_article <-file("/Users/max/Documents/UCSC/Summer 2022/(Local) Journalist Project - Income Dynamics Lab/first_article2.txt")
writeLines(c(first_article), file_article)
close(file_article)



# Python module that can now be used inside the R file
stemmer <- import("Stemmer")
pd <- import("pandas")
nltk <- import("nltk")
porter = stemmer$Stemmer('porter')

first_article_stems <- (porter$stemWords(first_article))

first_article_long <- paste(first_article_stems, collapse=" ")

tokens <- nltk$word_tokenize(first_article_long)

#Create the bigrams
bgs <- nltk$bigrams(tokens)

# compute frequency distribution for all the bigrams in the text
fdist <- nltk$FreqDist(bgs)

#########################

bigram_converted <- read.csv('/Users/max/Documents/UCSC/Summer 2022/(Local) Journalist Project - Income Dynamics Lab/converted_bigrams.csv')

view(bigram_converted)

myCorpus <- Corpus(VectorSource(bigram_converted))
tdm <- TermDocumentMatrix(myCorpus)

#plot wordcloud to show most frequent words
wordcloud(tdm
          , scale=c(5,0.5)     # Set min and max scale
          , max.words=100      # Set top n words
          , random.order=FALSE # Words in decreasing freq
          , rot.per=0.35       # % of vertical words
          , use.r.layout=FALSE # Use C++ collision detection
          , colors=brewer.pal(8, "Dark2"))
#test_ngram <- tokens_ngrams(toks, n = 2:4)
toks2 <- tokens_ngrams(toks, n = 2, concatenator = " ")
head(test_ngram[[1]], 30)

