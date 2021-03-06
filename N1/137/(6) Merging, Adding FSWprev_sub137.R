
library(psych)

#####################################################################
###               Merging RT, N2, SlowWave datsets                ###
#####################################################################
setwd("C:/Users/Curt/Box Sync/Bruce Projects/Sequential Processing/PointByPoint Processing/Created by R_ArtRej")
path = "C:/Users/Curt/Box Sync/Bruce Projects/Sequential Processing/PointByPoint Processing/Created by R_ArtRej/"

#Reading in the RT, N2, SlowWave data sets. The ERP sets have had incorrect and art rejected trials removed.
RTdat = read.delim(paste(path, "RT/","RT_TrialsRemovedforMerging.txt", sep = ""))

N2dat = read.delim(paste(path, "N2/","AllSubs_TBTaverages_N2_Correct_withPrevious_EventFixed.txt", sep = ""))
                   
SlowWavedat = read.delim(paste(path, "SlowWave/", "AllSubs_TBTaverages_SlowWave_Correct_withPrevious_EventFixed.txt", sep = ""))

colnames(N2dat) <- c("Subject", "Trial", "Electrode", "N2curr", "Acc", "Condition", "notFirst", 
                  "prevCondTrigger", "prevCondAcc", "prevCond", "TrialCondition")

colnames(SlowWavedat) <- c("Subject", "Trial", "Electrode", "SlowWavecurr", "Acc", "Condition", "notFirst", 
                           "prevCondTrigger", "prevCondAcc", "prevCond", "TrialCondition")

#Merging just N2 and SlowWave first. Can's use "by" if the varibles aren't in both datasets.
N2_SlowWave_dat <- merge(N2dat, SlowWavedat, by = c("Subject", "Trial", "Electrode",
                                                       "Acc", "Condition", "notFirst", 
                                                       "prevCondTrigger", "prevCondAcc", "prevCond", "TrialCondition"))
head(N2_SlowWave_dat)
tail(N2_SlowWave_dat)

###RT data##
#Trial variable repeats 1:100 for each of the 8 blocks. Need to format Trial to be 1:800 for merge with ERP data sets.
#Subject 92 only has 700 trials so I add trial info to 92 separately and then rbind at the end.
#Makind data set with only 92.
#92
Sub92 <- RTdat[RTdat$Subject == 92,]
#Trial is 1 through 700.
Trial <-  rep(1:700)
#Add Trial column to the end of 92 dataset.
Sub92 <- cbind(Sub92, Trial)
#2
Sub2 <- RTdat[RTdat$Subject == 2,]
Trial <-  rep(1:797)
Sub2 <- cbind(Sub2, Trial)
#4
Sub4 <- RTdat[RTdat$Subject == 4,]
Trial <-  rep(1:782)
Sub4 <- cbind(Sub4, Trial)
#8
Sub8 <- RTdat[RTdat$Subject == 8,]
Trial <-  rep(1:799)
Sub8 <- cbind(Sub8, Trial)
#16
Sub16 <- RTdat[RTdat$Subject == 16,]
Trial <-  rep(1:798)
Sub16 <- cbind(Sub16, Trial)
#17
Sub17<- RTdat[RTdat$Subject == 17,]
Trial <-  rep(1:799)
Sub17 <- cbind(Sub17, Trial)
#19
Sub19 <- RTdat[RTdat$Subject == 19,]
Trial <-  rep(1:798)
Sub19 <- cbind(Sub19, Trial)
#30
Sub30 <- RTdat[RTdat$Subject == 30,]
Trial <-  rep(1:798)
Sub30 <- cbind(Sub30, Trial)
#59
Sub59 <- RTdat[RTdat$Subject == 59,]
Trial <-  rep(1:799)
Sub59 <- cbind(Sub59, Trial)
#70
Sub70 <- RTdat[RTdat$Subject == 70,]
Trial <-  rep(1:799)
Sub70 <- cbind(Sub70, Trial)
#72
Sub72 <- RTdat[RTdat$Subject == 72,]
Trial <-  rep(1:799)
Sub72 <- cbind(Sub72, Trial)
#74
Sub74 <- RTdat[RTdat$Subject == 74,]
Trial <-  rep(1:800)
Sub74 <- cbind(Sub74, Trial)

#Making data set without the above subjects.
sublist2 <- c(2,4,8,16,17,19,30,59,70,72,74,92)
RTdat <- RTdat[!RTdat$Subject %in% sublist2,]
describe(unique(RTdat$Subject))
#Trial is now 1 through 800. Had to use the same name (e.g., "Trial) here and above since the names need to be the same for rbind below.
Trial <-  rep(1:800, length(unique(RTdat$Subject)))
#Add Trial column to the end of RT dataset.
RTdat <- cbind(RTdat, Trial)

#Attach 92 to the dataset without 92.
RTdat <- rbind(RTdat,Sub2,Sub4,Sub8,Sub16,Sub17,Sub30,Sub59,Sub70,Sub72,Sub92)

#Remove variables not of interest.
RTdatshort <- RTdat[, c(2,27,28)]


#Merging RTdat with ERPdat. Using the previously merged RT data since it seems like the merge BY
#variables need to be in each dataset. So doing the ERPs first allows us to collapse the 
#variables that are common to the ERP data sets but not common to the RT data set.
#Note: it turns out that "all.y=TRUE" was not needed to maintain the columns in the ERP dataset that weren't contained in the RT data set.
#I'm not sure why I didn't need it.
RT_N2_SlowWave_dat_allERP <- merge(RTdatshort, N2_SlowWave_dat, by = c("Subject", "Trial")) 

#Remove "notfirst" and precCondTrigger.
Alldat <- RT_N2_SlowWave_dat_allERP[,c(-7,-8)]

colnames(Alldat) <- c("Subject", "Trial", "RT", "Electrode", "AccCurr", "CondCurr",
                           "AccPrev", "CondPrev", "Cell", "N2Curr", "SlowWaveCurr")

#For comparison purposes
Sub2 <- RT_N2_SlowWave_dat_allERP[RT_N2_SlowWave_dat_allERP$Subject == 2,]
Sub2 <- Sub2[order(Sub2$Trial),] 
tail(Sub2)

Sub2N2 <- N2dat[N2dat$Subject == 2,]
Sub2N2 <- Sub2N2[order(Sub2N2$Trial)]
tail(Sub2N2)

Sub137 <- Alldat[Alldat$Subject == 137,]
#####################################################################
###               Adding previous SlowWave variable               ###
#####################################################################

#setwd("C:/Users/psycworks/Desktop/Box Sync/Bruce Projects/Sequential Processing/PointByPoint Processing/Created by R_ArtRej")
#path = "C:/Users/psycworks/Desktop/Box Sync/Bruce Projects/Sequential Processing/PointByPoint Processing/Created by R_ArtRej/"

sublist <- c(137)

electrodeList = c("F3", "Fz", "F4", "FC3", "FCz", "FC4", "C3", "Cz", "C4")

# Hannah
#h <- 2
#i <- 8
#j <- "Fz"
Sub137$SlowWavePrev = NA
for (h in sublist){
  # h <- 2
  SubjectTemp <- Sub137[Sub137$Subject == h,]
  trials = sort(unique(SubjectTemp$Trial))
  prevTrials = trials-1
  for (i in trials[prevTrials %in% trials]) {
    for (j in electrodeList){
      Sub137$SlowWavePrev[Sub137$Subject == h & Sub137$Electrode == j & Sub137$Trial == i] <- Sub137$SlowWaveCurr[Sub137$Subject == h & Sub137$Electrode == j & Sub137$Trial == i-1]
    }
  }
}

write.table(Sub137, paste(path, "SlowWave/", "137_RT_N2_SlowWave_SlowWavePrev_EventFixed.txt", sep=""), sep = "\t", row.names = F)




