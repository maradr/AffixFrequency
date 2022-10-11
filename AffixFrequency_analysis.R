## Affix frequency effects in masked priming
## Behavioral study
## the experiment comprehends three tasks: 
## 1. Masked priming lexical decision;
## 2. Unprimed lexical decision;
## 3. 1-7 Scale Rating
## The present code contains data analysis to assess 
#(1) priming and (2) effects of interpretability for morphological nonwords

## Mara De Rosa & Davide Crepaldi
## SISSA - International school for advanced studies, Trieste. July, 2017

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

### Masked priming ####

#upload data
dataAll <- read.table("AffixFrequency_processedMaskedData.txt", header=T)
summary(dataAll)
dataAll$condition <- factor(dataAll$condition)
dataAll$relatedness <- factor(dataAll$relatedness)

# Outlier removal
source("Diagnostics.R")
diagnostics.f(dataAll$RT, dataAll$acc, dataAll$subjectID, dataAll$target, dataAll$lexicality, 'AffixFrequencyInterps_MPData') 

par(mfrow=c(1,2))
hist(dataAll$RT[dataAll$RT<500], breaks=seq(0,500,50)) #a few RTS around 100ms, they should go out
hist(dataAll$RT[dataAll$RT>1000], breaks=seq(1000,1500,50)) #no long RTs out
par(mfrow=c(1,1))


dataAcc <- subset(dataAll, lexicality=="word" & RT > 200 & subjectID!="SE23" & target!="prua" & RT>200)
dataRt <- subset(dataAcc, acc==1)
summary(dataRt)

#modeling
par(mfrow=c(1,3))

qqnorm(dataRt$RT)
qqnorm(log(dataRt$RT))
qqnorm(-1000/dataRt$RT) # inverse transform results to be the best
par(mfrow=c(1,1))




#### Model selection
#let's start from a model that considers all of the covariates
m1 <- lmer(-1000/RT ~ handedness + rotation + 
             scale(orderID) + scale(rtPrec) + scale(accPrec) + 
             scale(lengthtarget) + scale(old20target) + scale(freqtarget) + 
             scale(old20prime) + scale(lengthprime) + 
             (1|subjectID) + (1|target), data=dataRt, REML=F)
summary(m1)
m2 <- lmer(-1000/RT ~ scale(rtPrec) + scale(accPrec) + scale(freqtarget) + 
             (1|subjectID) + (1|target), data=dataRt, REML=F)

anova(m2,m1)

# Introducing the effect of interest:
dataRt$relatedness <- relevel(dataRt$relatedness, 'unrelated')
m3 <- lmer(-1000/RT ~ condition*relatedness + scale(freqtarget) + scale(rtPrec) + accPrec + (1|subjectID) + (1|target), data=dataRt, REML=F)
anova(m3,m2) 
summary(m3)

#Model Criticism - Baayen&Milin, 2010
m3 <- lmer(-1000/RT ~ condition*relatedness + scale(freqtarget) + scale(rtPrec) + accPrec + (1|subjectID) + (1|target), data=dataRt, REML=T)
m3a <- lmer(-1000/RT ~ condition*relatedness + scale(freqtarget) + scale(rtPrec) + accPrec + (1|subjectID) + (1|target), data=subset(dataRt, abs(scale(resid(m3)))<2.5), REML=T)
summary(m3a) #the pattern is unaltered

Anova(m3a, type=3)


####  Visualize interaction 
inv <- function(x){-1000/x}
plotLMER.fnc(m3a, fun=inv, pred="relatedness", intr=list("condition", levels(dataRt$condition), "end"), ylab="RT(ms)", addlines=T, main= 'condition*relatedness interaction')

### Bayes factor
## Bayes Factor analysis
dataBayes <- dataRt
dataBayes$invRT <- -1000/dataRt$RT
dataBayes$freqtarget <- scale(dataBayes$freqtarget)
dataBayes$rtPrec <- scale(dataBayes$rtPrec)

full <- lmBF(invRT ~ condition+relatedness + 
               condition:relatedness + 
               freqtarget + rtPrec + accPrec, 
             data=dataBayes, whichRandom = c("subjectID", "target"))

noInt <- lmBF(invRT ~ condition+relatedness + 
                freqtarget + rtPrec + accPrec, 
              data=dataBayes, whichRandom = c("subjectID", "target"))

noCond <- lmBF(invRT ~ relatedness + 
                 freqtarget + rtPrec + accPrec, 
               data=dataBayes, whichRandom = c("subjectID", "target"))

# H1 - interaction - over H0 - with no interaction (strength determined using the Lee & Wagenmakers, 2013, scale)
full/noInt #evidence against an iteraction between relatedness and condition
# (BF close to zero)
noInt/noCond #evidence against an effect of condition (BF close to zero)





### Interpretability for morphological nonwords ####

dataMorph <- subset(dataRt, condition=="morphological")

#Implicit index
mImplicit <- lmer(-1000/RT ~ relatedness*morphInterference  +
                 scale(freqtarget) + scale(rtPrec) + accPrec + 
                 (1|subjectID) + (1|target), data=dataMorph, REML=T)
summary(mImplicit)
Anova(mImplicit, type=3)

#Explicit index
mExplicit <- lmer(-1000/RT ~ relatedness*explInterp  +
                    scale(freqtarget) + scale(rtPrec) + accPrec + 
                    (1|subjectID) + (1|target), data=dataMorph, REML=T)
summary(mExplicit)
Anova(mExplicit, type=3)

## Bayes Factor analysis
dataBayesMorph <- subset(dataBayes, condition=="morphological")

BFimplicit <- lmBF(invRT ~ relatedness + morphInterference + relatedness:morphInterference + 
                freqtarget + rtPrec + accPrec, 
              data=dataBayesMorph, whichRandom = c("subjectID", "target"))

BFexplicit <- lmBF(invRT ~ relatedness + explInterp + relatedness:explInterp + 
                     freqtarget + rtPrec + accPrec, 
                   data=dataBayesMorph, whichRandom = c("subjectID", "target"))


NoIndex <- lmBF(invRT ~ relatedness + 
                 freqtarget + rtPrec + accPrec, 
               data=dataBayesMorph, whichRandom = c("subjectID", "target"))

# H1 - interaction - over H0 
BFimplicit/NoIndex
BFexplicit/NoIndex
#BF close to zero in both models, 
#supporting no effect of interpretability over the observed priming





