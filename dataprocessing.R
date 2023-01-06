rm(list=ls())

library(dplyr)
library(lubridate)

dataurl = "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
datadest = "stormdata.csv.bz2"
download.file(dataurl,datadest)
df <- read.csv(datadest)

# Use data from 2020 to present (more recent years are more complete and better answer the question)
df$BGN_DATE <- as.Date(df$BGN_DATE,format="%m/%d/%Y %H:%M:%S")
df <- df[df$BGN_DATE > as.Date('2000-01-01'),]

# Health effects over time
healtheffects <- as.data.frame(df %>% group_by(EVTYPE) %>% summarise(totalfatalities=sum(FATALITIES),totalinjuries=sum(INJURIES), .groups='drop'))
healtheffects <- healtheffects[order(-healtheffects$totalfatalities),]
injuryeffects <- healtheffects[order(-healtheffects$totalinjuries),]

# Economic effects over time
df$PROPDMGEXP[df$PROPDMGEXP == "K"] = "1000"
df$PROPDMGEXP[df$PROPDMGEXP == "M"] = "1000000"
df$PROPDMGEXP[df$PROPDMGEXP == "B"] = "1000000000"
df$PROPDMGEXP[df$PROPDMGEXP == ""] = "0"

df$CROPDMGEXP[df$CROPDMGEXP == "K"] = "1000"
df$CROPDMGEXP[df$CROPDMGEXP == "M"] = "1000000"
df$CROPDMGEXP[df$CROPDMGEXP == "B"] = "1000000000"
df$CROPDMGEXP[df$CROPDMGEXP == ""] = "0"

df$PROPDMG <- as.numeric(df$PROPDMGEXP)*df$PROPDMG
df$CROPDMG <- as.numeric(df$CROPDMGEXP)*df$CROPDMG
econeffects <- as.data.frame(df %>% group_by(EVTYPE) %>% summarise(totdamage=sum(CROPDMG) + sum(PROPDMG), .groups='drop'))
econeffects <- econeffects[order(-econeffects$totdamage),]
