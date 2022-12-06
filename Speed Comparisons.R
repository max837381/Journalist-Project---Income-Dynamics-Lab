# R script

library(pacman)
p_load(tidyverse, data.table, tictoc, arrow, duckdb)

tic("arrow")

wapo <- 
  arrow::read_csv_arrow("/Users/max/Desktop/Journalist Project - Income Dynamics Lab/think_tank_combined.csv", skip_empty_rows = FALSE)
#as_data_frame = FALSE)



toc("arrow")

tic("fread")

wapo <- fread('wapo_articles.csv')

toc("fread")


rm(wapo)


