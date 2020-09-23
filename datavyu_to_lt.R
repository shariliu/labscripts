# Converting Datavyu Data into Looking Times
# Shari Liu, last updated 9/23/2020

# This script takes as input a .csv file generated from Datavyu,
# and calculates looking duration for each trial specified in the csv

#------- FILL IN ----------------
# your working directory (i.e. where the csv lives on your computer)
setwd("/Users/shariliu/Dropbox (MIT)/Research/Studies/Published_Studies/LUMI/")

# the filename you want to process
filename <- "LUMIr_10-LA.csv"

# Important: If you encounter issues, go to Packages > search dplyr > 
# and uncheck and recheck the box next to dplyr. And double check your inputs.

# Do you see an error message you don't understand? Try Googling it,
# and then if you still have trouble, contact Shari.

#------- DO NOT EDIT WITHOUT ASKING SHARI FIRST----------------
library(tidyverse, dplyr)

data <- read.csv(filename, header = TRUE)
names(data) <- tolower(names(data))

# there might be ways to condense this, but here's what I've got that works!

# make new new tibbles: one for looks away, and one for total trial length
off <- data %>%
  select(off.onset, off.offset, off.code01) %>%
  rename(onset=off.onset, offset=off.offset, crit=off.code01) %>%
  mutate(event = 'off', trial = NA)

trials <- data %>%
  select(trial.onset, trial.offset, trial.code01) %>%
  rename(onset = trial.onset, offset = trial.offset, trial = trial.code01) %>%
  mutate(event = 'trial') %>%
  na.omit

# calculate which trial looks off belong to based on onsets/offsets
for (i in 1:nrow(off)) {
  for (j in 1:nrow(trials)) {
    if (trials$onset[j] <= off$onset[i] & trials$offset[j] >= off$offset[i]) {
      off$trial[i] <- trials$trial[j]
    }
  }
}

# calculate looks on per subject per trial
looks.on <- merge(trials, off, all=TRUE) %>%
  mutate(subj = filename, duration = (offset-onset)/1000) %>%
  group_by(trial) %>%
  mutate(duration.on = sum(duration[event=="trial"]-sum(duration[event=="off"]))) %>%
  distinct(duration.on)
  
DT::datatable(looks.on)

