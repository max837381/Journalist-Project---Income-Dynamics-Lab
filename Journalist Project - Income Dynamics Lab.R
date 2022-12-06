rm(list = ls())
set.seed(0)
library(pacman)
p_load(gamlr,tm, textir, wordcloud2)

data(congress109)
dim(congress109Counts)
congress109Counts[c("Barack Obama", "John Boehner"), 995:998]


head(congress109Ideology)

assocs <- drop(cov(congress109Ideology$repshare, as.matrix(congress109Counts)))
assocs <- assocs[order(abs(assocs), decreasing = TRUE)] # sort by magnitude
assocs[1:50]

assocs_df <- data.frame(names(assocs), abs(assocs)) # wordcloud2 takes a dataframe
set.seed(0)
wordcloud2(assocs_df[1:50, ], shape = "circle", rotateRatio = 0,
           color = ifelse(as.vector(assocs[1:50]) > 0, "red", "blue"))


x <- congress109Counts
y <- congress109Ideology$repshare
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


# Another common transformation is to change each entry of X into an indicator for whether the entry is
# positive. That way, X tracks whether a word was ever used in the document.


lassoslant_ind <- cv.gamlr(x > 0, y)
B <- coef(lassoslant_ind$gamlr)[-1, ]

# Low repshare (Dems)
names(sort(B)[1:10])

# High repshare (Repubs)
names(sort(-B)[1:10])

cat("minium CV error, levels:", min(lassoslant$cvm), "\n")

cat("minium CV error, proportions:", min(lassoslant_prop$cvm),
    "\n")

cat("minium CV error, indicators:", min(lassoslant_ind$cvm),
    "\n")

lassoslant_all <- cv.gamlr(cbind(x, x_prop, x > 0), y)
min(lassoslant_all$cvm)


setwd("/Users/max/Documents/UCSC/Summer 2022/Journalist Project - Income Dynamics Lab/hein-daily")

fname <- "speeches_113.txt"
notes <- readPlain(elem = list(content = readLines(fname)),
                     id = fname, language = "en")

#files <- Sys.glob("*.txt")

reader <- function(fname) {
  txt <- readPlain(elem = list(content = readLines(fname)),
                   id = fname, language = "en")
  return(txt)
}  

#notes <- lapply(files, reader)

docs <- Corpus(VectorSource(notes))

docs <- tm_map(docs, content_transformer(tolower))

docs <- tm_map(docs, content_transformer(removeNumbers))

docs <- tm_map(docs, content_transformer(removePunctuation))

stopwords("SMART")[1:10]

docs <- tm_map(docs, content_transformer(removeWords), stopwords("SMART"))

docs <- tm_map(docs, content_transformer(stripWhitespace))

dtm <- DocumentTermMatrix(docs)
dtm


# Outcome is measure of slant


