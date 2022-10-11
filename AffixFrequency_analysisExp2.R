## Affix frequency effects in masked priming
## Behavioral study
## Experiment 2
## Masked priming lexical decision
## Mara De Rosa
## SISSA - International school for advanced studies, Trieste. July, 2021

#clean up the workspace
rm(list=ls())
#set working directory
wd <- ('~/Documents/SISSA-OngoingStuff/SL1/')
setwd(wd)

#upload libraries
library(lme4)
library(lmerTest)
library(car)
library(effects)
library(languageR)
library(BayesFactor)
library(ggplot2)

#upload data
dataAll <- read.table("AffixFrequency_processedExp2.txt", header=T)
summary(dataAll)
dataAll$condition <- factor(dataAll$condition)
dataAll$relatedness <- factor(dataAll$relatedness)

# Outlier removal
source("Diagnostics.R")
diagnostics.f(dataAll$RT, dataAll$acc, 
              dataAll$subjectID, dataAll$target, dataAll$target_lexicality, 'AffixFrequencyExp2_MPData') 
#visualizing the distribution of RTs
par(mfrow=c(1,2))
hist(dataAll$RT[dataAll$RT<500], breaks=seq(0,500,50)) #few no responses to remove
hist(dataAll$RT[dataAll$RT>1000], breaks=seq(1000,1500,50)) #no long RTs out
par(mfrow=c(1,1))

#Selecting the relevant datapoints
dataAcc <- subset(dataAll, target_lexicality=="word" & RT > 200 & subjectID !="EDP28")
dataRt <- subset(dataAcc, acc==1)

par(mfrow=c(1,3))
qqnorm(dataRt$RT)
qqnorm(log(dataRt$RT))
qqnorm(-1000/dataRt$RT) # inverse transform results to be the best
par(mfrow=c(1,1))




#### Model selection
#let's start from a model that considers all of the covariates
m1 <- lmer(-1000/RT ~ handedness + 
             scale(orderID) + scale(rtPrec) + scale(accPrec) + 
             scale(lengthtarget) + scale(old20target) + scale(freqtarget) + 
             scale(old20prime) + scale(lengthprime) + 
             (1|subjectID) + (1|target), data=dataRt, REML=F)
summary(m1)

m2 <- lmer(-1000/RT ~ scale(orderID) + scale(rtPrec) + scale(accPrec) +
             scale(lengthtarget) + scale(old20target) + scale(freqtarget) + scale(lengthprime)+
             (1|subjectID) + (1|target), data=dataRt, REML=F)

anova(m2,m1)

# Introducing the effect of interest:
dataRt$relatedness <- relevel(dataRt$relatedness, 'unrelated')
dataRt$condition <- relevel(dataRt$condition, 'LF')
m3 <- lmer(-1000/RT ~ condition*relatedness +
                 scale(orderID) + scale(rtPrec) + scale(accPrec) +
                 scale(lengthtarget) + scale(old20target) + scale(freqtarget) + scale(lengthprime)+
                 (1|subjectID) + (1|target), data=dataRt, REML=F)

anova(m2,m3) # significant improvement

Anova(m3, type=3)

#Model Criticism - Baayen&Milin, 2010
m3_a <- lmer(-1000/RT ~ condition*relatedness +
                        scale(orderID) + scale(rtPrec) + scale(accPrec) +
                        scale(lengthtarget) + scale(old20target) + scale(freqtarget) + scale(lengthprime)+
                        (1|subjectID) + (1|target), data=subset(dataRt, abs(scale(resid(m3)))<2.5), REML=T)

Anova(m3_a, type=3) # the effects of interest stay unaltered


####  Visualize interaction 
inv <- function(x){-1000/x}
plotLMER.fnc(m3_a, fun=inv, pred="relatedness", intr=list("condition", levels(dataRt$condition), "end"), ylab="RT(ms)", addlines=T, main= 'condition*relatedness interaction')




## Bayes Factor analysis ####
dataBayes <- dataRt
dataBayes$invRT <- -1000/dataRt$RT
dataBayes$freqtarget <- scale(dataBayes$freqtarget)
dataBayes$rtPrec <- scale(dataBayes$rtPrec)
dataBayes$orderID <- scale(dataBayes$orderID)
dataBayes$accPrec <- scale(dataBayes$accPrec)
dataBayes$lengthtarget <- scale(dataBayes$lengthtarget)
dataBayes$old20target <- scale(dataBayes$old20target)
dataBayes$lengthprime <- scale(dataBayes$lengthprime)
  


full <- lmBF(invRT ~ condition+relatedness + 
               condition:relatedness + 
               freqtarget + lengthtarget + old20target + lengthprime+
               accPrec + rtPrec + orderID, 
             data=dataBayes, whichRandom = c("subjectID", "target"))

noInteraction <- lmBF(invRT ~ condition+relatedness + 
                        freqtarget + lengthtarget + old20target + lengthprime+
                        accPrec + rtPrec + orderID, 
              data=dataBayes, whichRandom = c("subjectID", "target"))

# H1 - interaction - over H0 - with no interaction (strength determined using the Lee & Wagenmakers, 2013, scale)
full/noInteraction #evidence against an interaction between relatedness and condition
# (BF close to zero)
