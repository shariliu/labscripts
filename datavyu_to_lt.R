# Converting Datavyu Data into Looking Times
# Shari Liu

library(tidyverse, lmer)
wd <- "/Users/shariliu/Documents/HarvardLDS/Studies/LUMI/liu_materials/LUMI_Coding/Reliability/Daisy Datavyu"

setwd(wd) ## change to your local directory!
filename <- "LUMI2_STG_5-JS_DE.csv"

#-------
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

