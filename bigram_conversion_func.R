bigram_help <- cat("Function needs 5 arguments in the following order: df, string for id, string for text (both strings must be a column name in df), output_df (TRUE = df FALSE =  Document-Feature-Matrix (output of function), sum_counts TRUE/FALSE (summarize based on ID)")
bigram_conversion <- function(df,id_column,text_column, output_df, sum_counts) {
  
  # rename columns in order to put them into a corpus object
  colnames(df)[match(id_column,colnames(df))] <- "doc_id"
  colnames(df)[match(text_column,colnames(df))] <- "text"
  
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
  tic("bigram conversion - finished")
  tokenz[3]
  tokenz <- tokens_remove(tokenz, pattern = stopwords("en"))
  tokenz[3]
  tokenz <- tokens_wordstem(tokenz, language = "en")
  tokenz[3]
  toks_ngram <- tokens_ngrams(tokenz, n = 2, concatenator = " ")
  
  toks_dfm <- dfm(toks_ngram)
  if (output_df==TRUE) {
    DF <- tidytext::tidy(toks_dfm)
  } else {
    DF <- toks_ngram
  }
  #DF <- tidytext::tidy(toks_dfm)
  
  if (sum_counts==TRUE) {
    x <- DF %>%
      group_by(document, term) %>%
      summarise(Frequency = sum(count))
  } else {
    x <- DF
  }
  
  return(x)
}