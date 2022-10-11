## Affix frequency effects in masked priming
## Behavioral study
## Experiment 2
## Masked priming lexical decision;
## Mara De Rosa
## SISSA - International school for advanced studies, Trieste. April, 2021


#clean up the workspace
rm(list=ls());

#set working directory
wd <- ('~/Documents/SISSA-OngoingStuff/SL1/')
setwd(wd)

#upload libraries
library(plyr)
library(dplyr)
library(lme4)
library(lmerTest)

## Upload stimuli features
stimuli <- read.table(paste0(wd,"SL1_2stimulifeatures.txt"), header= T, dec='.')
summary(stimuli)

## Upload the raw data from the masked priming task
setwd(paste0(wd,'AffixFrequency_rawData/SecondExperiment_outputs'))
filenames <- list.files(full.names=TRUE, include.dirs = FALSE, pattern =".txt$")
import.list <- llply(filenames, read.table, header=T)


#bring back wd to the main directory
setwd(wd);
for (i in 1:length(import.list))
{
  #create a var tracking trial position within the randomised list
  import.list[[i]]$orderID <- 1:nrow(import.list[[i]])
  #calculate accuracy for each trial
  import.list[[i]]$acc <- ifelse(import.list[[i]]$response==import.list[[i]]$lexicality, 1, 0)
  import.list[[i]]$response <- factor(import.list[[i]]$response)
  import.list[[i]]$lexicality <- factor(import.list[[i]]$lexicality)
  
  #calculate RT of the preceding trial, if a correct response was given
  import.list[[i]]$rtPrec <- mean(import.list[[i]]$RT[import.list[[i]]$acc==1])
  import.list[[i]]$rtPrec[2:nrow(import.list[[i]])] <- import.list[[i]]$RT[1:(nrow(import.list[[i]])-1)]
  import.list[[i]]$accPrec <- 1
  import.list[[i]]$accPrec[2:nrow(import.list[[i]])] <- import.list[[i]]$acc[1:(nrow(import.list[[i]])-1)]
  
  print(i)
}



#merge all sbjs into a single data frame
allSbjMasked <- Reduce(function(x, y) merge(x, y, all=TRUE), import.list)

# Fix some variables (case&factors)
allSbjMasked$subjectID <- factor(toupper(allSbjMasked$subjectID))
allSbjMasked$experimentID <- factor(toupper(allSbjMasked$experimentID))
allSbjMasked$handedness <- factor(toupper(allSbjMasked$handedness))
allSbjMasked$rotation <- factor(toupper(allSbjMasked$rotation))
allSbjMasked$accPrec <- factor(allSbjMasked$accPrec)
allSbjMasked$target <- tolower(allSbjMasked$target)
colnames(allSbjMasked)[10] <- "target_lexicality"
#merge the collected data with the stimuli features
MaskedData <- merge(allSbjMasked, stimuli,  by=c('trial_ID', 'prime', 'target_lexicality', 'target'), all =T)


#get rid of examples, training and warm up trials
MaskedData <- subset(MaskedData, condition %in% c("HF", "LF", "opaque_word", "morph"))
MaskedData$condition <- factor(MaskedData$condition)
MaskedData$relatedness <- factor(MaskedData$relatedness)
MaskedData$trial_ID <- factor(MaskedData$trial_ID)

#convert RTs from seconds to milliseconds
MaskedData$RT <- MaskedData$RT*1000
MaskedData$rtPrec <- MaskedData$rtPrec*1000

#final double check
summary(MaskedData)

#export dataframes
write.table(MaskedData, "AffixFrequency_processedExp2.txt", row.names = F)

