# Combine Think Tank Files

library(pacman)
p_load(easycsv)

dir <- paste(getwd(), "thinktankdata", sep="/")

loadcsv_multi(dir)

CATO$slant <- "R"
`Heritage Foundation`$slant <- "R"

`Center For American Progress Articles new`$slant <- "D"
urban_inst$slant <- 'D'

df <- rbind(CATO, `Center For American Progress Articles new`, `Heritage Foundation`,  urban_inst)
df[!complete.cases(df),]

df <- df[complete.cases(df),]

rm(CATO)
rm(`Center For American Progress Articles new`)
rm(`Heritage Foundation`)
rm(urban_inst)

df$slant <- factor(df$slant)

write.csv(df, paste(getwd(),"think_tank_combined.csv", sep = "/"))