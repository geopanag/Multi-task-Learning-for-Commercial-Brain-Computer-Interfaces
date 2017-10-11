#----------------------------------------
# Exploratory Analysis of the CMU Dataset
#    1. Load Dataset 
#    2. Label Density Plots for all features
#    3. Subject boxplots between class
#    4. Store the dataset
#---------------------------------------

setwd("Path/to/cmu")

libs<-c("dplyr","reshape2","ggplot2","gridExtra","xtable")
suppressPackageStartupMessages(sapply(libs,require,character.only = T))


##---------------------  Load Data, Rename and Subset
dat <- read.csv("EEG data.csv",head=F)
names(dat)=c("Subject","Video","Attention","Meditation","Raw","Delta","Theta","Alpha1","Alpha2","Beta1","Beta2","Gamma1","Gamma2","Expected","Label")
dat = dat %>% select(-Expected,-Attention,-Meditation)


##--------------------- Confused VS Non Confused Density Plots per Feature
frequency_plot = dat %>% select(-Video)
frequency_plot = melt(frequency_plot,id.vars=c("Subject","Label"))

frequency_plot$value = log(frequency_plot$value)

ggplot(frequency_plot[frequency_plot$Subject==2,],aes(x=value,y=..scaled..,fill=as.factor(Label))) + 
  geom_density(alpha = .3)+scale_color_manual(values = c("red", "green"))+
  xlab("")+ylab("")+ facet_wrap(~variable,ncol=2)+labs(fill="Label")+
  ggtitle("CMU Feature Distributions (Confused vs Non Confused)")+
  theme(plot.title = element_text(size=12))

ggsave("../../Paper/Figures/cmu_densities.png")


##--------------------- Subject Boxplots by label
remove_outiers_and_scale <- function(x){
  extremes = boxplot.stats(x)$stats[c(1,5)]
  x[x<quantile(x,.025) | x>quantile(x,.975) ]=NA
  x = (x-min(x,na.rm=T))/(max(x,na.rm=T)-min(x,na.rm=T))
  return(x)
} 

to_box = melt(dat %>% select(-Video) %>% filter(Subject!=6) %>%
                #group_by(Subject) %>% 
                mutate_each(funs(remove_outiers_and_scale),-Subject,-Label),id.vars=c("Subject","Label"))

to_box$Confused = to_box$Label==1
ggplot(to_box, aes(x=as.factor(Subject),y=value,fill=to_box$Confused))+
  geom_boxplot(outlier.shape=NA)+facet_wrap(~variable,ncol=2)+labs(x="Subject",y="",fill="Confused")+
  theme(plot.title = element_text(size=12))+
  scale_fill_manual(values = c("white", "black"))


ggsave("../../Figures/cmu_boxplots.png",width=6,height=8)


dat = dat %>% select(-Video) %>% filter(Subject!=6)
dat$Subject = as.numeric(dat$Subject)+1
write.csv(dat,"../cmu.csv",row.names=F)



