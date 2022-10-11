## Affix frequency effects in masked priming
## Behavioral study
## the experiment comprehends three tasks: 
## 1. Masked priming lexical decision;
## 2. Unprimed lexical decision;
## 3. 1-7 Scale Rating
## The present code contains preprocessing steps for the masked priming data
## an analysis of the additional tasks, resulting in two measures of interpretability; 
## Mara De Rosa & Davide Crepaldi
## SISSA - International school for advanced studies, Trieste. July, 2017


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

# MASKED PRIMING ####
## Upload the stimuli features
stimuli <- read.table(paste0(wd,"AffixFrequency_stimuli_MP.txt"), header= T, dec='.')
summary(stimuli)

## Upload the raw data from the masked priming task
setwd(paste0(wd,'AffixFrequency_rawData/MaskedPriming_outputs'))
filenames <- list.files()
filenames <- filenames[grep("txt$", filenames)]
import.list <- llply(filenames, read.table)

#bring back wd to the main directory
setwd(wd);
for (i in 1:length(import.list))
{
  #create a var tracking trial position within the randomised list
  import.list[[i]]$orderID <- 1:nrow(import.list[[i]])
  
  #calculate accuracy for each trial
  import.list[[i]]$V9 <- as.character(import.list[[i]]$V9)
  import.list[[i]]$V10 <- as.character(import.list[[i]]$V10)
  import.list[[i]]$acc <- ifelse(import.list[[i]]$V9==import.list[[i]]$V10, 1, 0)
  import.list[[i]]$V9 <- factor(import.list[[i]]$V9)
  import.list[[i]]$V10 <- factor(import.list[[i]]$V10)
  
  #calculate RT of the preceding trial, if a correct response was given
  import.list[[i]]$rtPrec <- mean(import.list[[i]]$V8[import.list[[i]]$acc==1])
  import.list[[i]]$rtPrec[2:nrow(import.list[[i]])] <- import.list[[i]]$V8[1:(nrow(import.list[[i]])-1)]
  import.list[[i]]$accPrec <- 1
  import.list[[i]]$accPrec[2:nrow(import.list[[i]])] <- import.list[[i]]$acc[1:(nrow(import.list[[i]])-1)]
  
  print(i)
}



#merge all sbjs into a single data frame
allSbjMasked <- Reduce(function(x, y) merge(x, y, all=TRUE), import.list)

#fix headers
colnames(allSbjMasked)[1:10] <- c('subjectID', 'experimentID','rotation','handedness', 'trialID', 'prime', 'target', 'RT',	'response',	'lexicality')

# Fix some variables (case&factors)
allSbjMasked$subjectID <- factor(toupper(allSbjMasked$subjectID))
allSbjMasked$experimentID <- factor(toupper(allSbjMasked$experimentID))
allSbjMasked$handedness <- factor(toupper(allSbjMasked$handedness))
allSbjMasked$accPrec <- factor(allSbjMasked$accPrec)
allSbjMasked$target <- tolower(allSbjMasked$target)

#merge the collected data with the stimuli features
MaskedData <- merge(stimuli, allSbjMasked, by=c('trialID', 'prime', 'lexicality', 'target'), all =T)


#get rid of examples, training and warm up trials
IDsofInterest <- c("^1", "^2", "^3")
MaskedData <- MaskedData[grep(paste(IDsofInterest,collapse="|"), MaskedData$trialID), ]
MaskedData$condition <- factor(MaskedData$condition)
MaskedData$relatedness <- factor(MaskedData$relatedness)

#convert RTs from seconds in milliseconds
MaskedData$RT <- MaskedData$RT*1000
MaskedData$rtPrec <- MaskedData$rtPrec*1000

#final double check
summary(MaskedData)

#clean up the workspace, but keep track of the new dataframe
rm(list= ls()[!(ls() %in% c('MaskedData','wd'))])


# UNPRIMED LEXICAL DECISION ####

#import stimuli features for the LDT
stimFeatures <- read.table(paste0(wd,"AffixFrequency_stimuli_LDRating.txt"), header= T, dec='.')
summary(stimFeatures) 
#there are some filler repetitions across different lists, creating an inconsistency with the trialIDs.
stimFeatures$trialID <- NULL
stimFeatures <- unique(stimFeatures)


## Upload the raw data from the lexical decision task
setwd(paste0(wd,'AffixFrequency_rawData/LexicalDecision_outputs'))
filenames <- list.files()
filenames <- filenames[grep("txt$", filenames)]
import.list <- llply(filenames, read.table)

#bring back wd to the main directory
setwd(wd)

for (i in 1:length(import.list))
{
  #create a var tracking trial position within the randomised list
  import.list[[i]]$orderIDLD <- 1:nrow(import.list[[i]])
  #calculate accuracy for each trial
  import.list[[i]]$V8 <- as.character(import.list[[i]]$V8)
  import.list[[i]]$V9 <- as.character(import.list[[i]]$V9)
  import.list[[i]]$accLD <- ifelse(import.list[[i]]$V8==import.list[[i]]$V9, 1, 0)
  import.list[[i]]$V8 <- factor(import.list[[i]]$V8)
  import.list[[i]]$V9 <- factor(import.list[[i]]$V9)
  
  #calculate RT of the preceding trial, if a correct response was given
  import.list[[i]]$rtPrecLD <- mean(import.list[[i]]$V7[import.list[[i]]$accLD==1])
  import.list[[i]]$rtPrecLD[2:nrow(import.list[[i]])] <- import.list[[i]]$V7[1:(nrow(import.list[[i]])-1)]
  import.list[[i]]$accPrecLD <- 1
  import.list[[i]]$accPrecLD[2:nrow(import.list[[i]])] <- import.list[[i]]$accLD[1:(nrow(import.list[[i]])-1)]
  
  print(i)
};

#merge all sbjs into one single data frame
allSbjLD <- Reduce(function(x, y) merge(x, y, all=TRUE), import.list)
#fix headers
colnames(allSbjLD)[1:9] <- c('subjectID', 'experimentID','rotation','handedness', 'trialID', 'target', 'RT_LD',	'Response_LD',	'lexicality_LD');


# Fix case and factors
allSbjLD$subjectID <- factor(toupper(allSbjLD$subjectID))
allSbjLD$experimentID <- factor(toupper(allSbjLD$experimentID))
allSbjLD$handedness <- factor(toupper(allSbjLD$handedness))
allSbjLD$rotation <- factor(allSbjLD$rotation)
allSbjLD$trialID <- factor(allSbjLD$trialID)
allSbjLD$target <- tolower(allSbjLD$target)

##merge with the stimfeatures
LexicalDecision <- merge(allSbjLD, stimFeatures, by=c("target"), all=T)


#get rid of example, training, warm up and filler items
IDsofInterest <- c("^1", "^2", "^3", "^4");
LexicalDecision <- LexicalDecision[grep(paste(IDsofInterest,collapse="|"), LexicalDecision$trialID), ]
LexicalDecision$condition <- factor(LexicalDecision$condition)

#final check
summary(LexicalDecision)

#transform RTs
LexicalDecision$RT_LD <- LexicalDecision$RT_LD*1000
LexicalDecision$rtPrecLD <- LexicalDecision$rtPrecLD*1000


#clean up the workspace, but keep track of the new dataframes
rm(list= ls()[!(ls() %in% c('MaskedData', 'LexicalDecision', 'wd'))])

### We now need to model the lexical decision data to extract the morphological sensitivity index. 

source("DiagnosticsNW.R")
diagnostics.f(LexicalDecision$RT_LD, LexicalDecision$accLD, LexicalDecision$subjectID, LexicalDecision$target, LexicalDecision$lexicality_LD, "AffixFrequencyInterps_LDData")
#we take out sbj EP37 because of too many errors on nonword targets.
#several nonword items had very few correct rejections

par(mfrow=c(1,2))
hist(LexicalDecision$RT[LexicalDecision$RT<400], breaks=seq(0,400,50)) #a few no responses, which we'll obviously take out
hist(LexicalDecision$RT[LexicalDecision$RT>1000], breaks=seq(1000,2000,50)) #no obvious outliers here
par(mfrow=c(1,1))


#we compute the relevant datasets for accuracy and RT modeling
dataAcc <- subset(LexicalDecision, lexicality_LD=="nonword" & Response_LD!="NoResponse" & subjectID!="EP37")
dataRt <- subset(dataAcc, accLD==1)


#modeling
par(mfrow=c(1,3))
qqnorm(dataRt$RT)
qqnorm(log(dataRt$RT))
qqnorm(-1000/dataRt$RT) #best option 
par(mfrow=c(1,1))


m1 <- lmer(-1000/RT_LD ~ scale(lengthtarget) + scale(Old20target) + condition + (1|subjectID) + (1|target), data=dataRt) 
summary(m1) #no strong effect of old20; significant effect of condition in correct rejection times.


#we're now extracting the random effects frrom the modeling to gather an implicit index of interference induced by complex nonwords.
secondaryMeasures <- data.frame(ranef(m1)$target)
secondaryMeasures$target <- rownames(secondaryMeasures)  
colnames(secondaryMeasures)[1] <- "morphInterference"

#let's look at the distribution of implicit Interference scores
hist(secondaryMeasures$morphInterference)


rm(list= ls()[!(ls() %in% c('MaskedData', 'LexicalDecision', 'secondaryMeasures', 'wd'))])

# RATING ####

setwd(paste0(wd,'AffixFrequency_rawdata/Rating_outputs'))
filenames <- list.files()
filenames <- filenames[grep("txt$", filenames)]
import.list <- llply(filenames, read.table)

#bring back wd to the main directory
setwd(wd)

for (i in 1:length(import.list))
{
  #create a var tracking trial position within the randomized list
  import.list[[i]]$orderIDRating <- 1:nrow(import.list[[i]])
}

#merge all sbjs into one single data frame
allSbjRating <- Reduce(function(x, y) merge(x, y, all=TRUE), import.list)
#fix headers
colnames(allSbjRating)[1:7] <- c('subjectID', 'experimentID','rotation', 'trialID', 'target',	'ratingscore', 'RT_Rating')

#Turn global variables to uppercase
allSbjRating$subjectID <- factor(toupper(allSbjRating$subjectID))
allSbjRating$experimentID <- factor(toupper(allSbjRating$experimentID))


#do we need to std by subject?
temp1 <- aggregate(allSbjRating$ratingscore, list(allSbjRating$subjectID), mean)
temp2 <- aggregate(allSbjRating$ratingscore, list(allSbjRating$subjectID), sd)
hist(temp1$x)
hist(temp2$x) #sbj-wise means and sds vary, better to have a sbj std

names(temp1) <- c("subjectID","meanRatingscore")
names(temp2) <- c("subjectID","sdRatingscore")
temp1 <- merge(temp1,temp2)
rm(temp2)

allSbjRating <- merge(allSbjRating, temp1, by="subjectID")
rm(temp1)
allSbjRating$RatingscoreStd <- (allSbjRating$ratingscore - allSbjRating$meanRatingscore) / allSbjRating$sdRatingscore
summary(allSbjRating)

temp1 <- aggregate(allSbjRating$RatingscoreStd, list(allSbjRating$target), mean)
names(temp1) <- c("target","explInterp")
secondaryMeasures <- merge(secondaryMeasures, temp1, by="target")
rm(temp1)

cor.test(secondaryMeasures$morphInterference, secondaryMeasures$explInterp)
plot(secondaryMeasures$morphInterference, secondaryMeasures$explInterp)
abline(lm(secondaryMeasures$explInterp ~secondaryMeasures$morphInterference), col="blue")


#### Exporting Final dataFrames ####
MaskedData <- merge(MaskedData, secondaryMeasures, by.x="prime", by.y="target", all.x=T)
LexicalDecision <- merge(LexicalDecision, secondaryMeasures[, c("target", "explInterp")], by="target", all.x=T)


#export dataframes
write.table(MaskedData, "AffixFrequency_processedMaskedData.txt", row.names = F)
write.table(LexicalDecision, "AffixFrequency_processedLDData.txt", row.names = F)

