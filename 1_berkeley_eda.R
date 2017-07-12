#------------------------------------------------------------------------------------
# Exploratory Analysis of the Berkeley Dataset
#    1. Load Dataset and Mung it to fit the requirements of the experiment
#    2. Create Labelwise Density Plots for all features
#    3. Create boxplots for the distribution of each class, by subject and feature
#------------------------------------------------------------------------------------


setwd("Paper/Data/berkeley")


libs<-c("dplyr","reshape2","ggplot2","gridExtra","xtable","tidyr")
suppressPackageStartupMessages(sapply(libs,require,character.only = T))


##--------------------- Load Data, Rename and Subset
eeg = read.csv("eeg-data.csv",stringsAsFactors = F)

eeg$label[grepl("color",eeg$label,ignore.case = TRUE)] <- "color"
eeg$label[grepl("math",eeg$label,ignore.case = TRUE)] <- "math"
eeg$label[grepl("items",eeg$label,ignore.case = TRUE)] <- "items"
eeg$label[grepl("video",eeg$label,ignore.case = TRUE)] <- "video"
eeg$label[grepl("music",eeg$label,ignore.case = TRUE)] <- "music"
eeg$label[grepl("relax",eeg$label,ignore.case = TRUE)] <- "relax"
eeg=eeg[!grepl("Instruction",eeg$label,ignore.case = TRUE),]
eeg=eeg[!grepl("ready",eeg$label,ignore.case = TRUE),]
eeg=eeg[!grepl("pair",eeg$label,ignore.case = TRUE),]
eeg = eeg[!grepl("blink",eeg$label,ignore.case = TRUE),]

eeg = eeg %>% filter(signal_quality == 0,label!="unlabeled")%>%
  select(-browser_latency, -reading_time,-createdAt, -updatedAt, -signal_quality,-attention_esense,-meditation_esense,-X)

eeg$id = as.factor(eeg$id)
names(eeg)=c("Subject","Time","Power","Raw","Label")


##---------------------  Extract relative time for each subject
eeg$Time = as.POSIXct(eeg$Time)

eeg$RelativeTime = c()
for(s in unique(eeg$Subject)){
  eeg$RelativeTime[eeg$Subject==s] = c(0,cumsum(as.numeric(diff(eeg$Time[eeg$Subject==s]))))
}

eeg$Time = NULL
eeg$RelativeTime = NULL

##---------------------  Unlist frequency and Raw features
freq_names = c("Delta",
               "Theta",
               "Alpha1",
               "Alpha2",
               "Beta1",
               "Beta2",
               "Gamma1",
               "Gamma2")

eeg = eeg %>% separate(Power, into = freq_names, sep = ",")
eeg[,freq_names] = lapply(eeg[,freq_names],function(x) as.numeric( gsub("\\]|\\[","",x)))
eeg$Raw = unlist(lapply(eeg$Raw,function(x) mean(as.numeric(strsplit(gsub("\\]|\\[","",x), ",")[[1]]))))


eeg$Active = grepl("math|items|color",eeg$Label)


##--------------------- Active VS Passive Density Plots per Feature
frequency_plot = melt(eeg %>% select(-Label),id.vars=c("Subject","Active"))
frequency_plot = melt(eeg %>% select(-Active),id.vars=c("Subject","Label"))

frequency_plot$value = log(frequency_plot$value)

ggplot(frequency_plot[frequency_plot$Subject==3,],aes(x=value,y=..scaled..,fill=as.factor(Label))) +
  geom_density(alpha = .2)+#scale_color_manual(values = c("red", "green"))+
  xlab("")+ylab("")+ facet_wrap(~variable,ncol=2)+labs(fill="Label")+
#  ggtitle("Berkeley Feature Distributions (Active vs Passive Stimuli)")+
  theme(plot.title = element_text(size=12))

ggsave("../../Figures/berkeley_densities.png")



##--------------------- Subject Boxplots by label
remove_outiers_and_scale <- function(x){
  extremes = boxplot.stats(x)$stats[c(1,5)]
  x[x<quantile(x,.025) | x>quantile(x,.975) ]=NA
  x = (x-min(x,na.rm=T))/(max(x,na.rm=T)-min(x,na.rm=T))
  return(x)
} 


to_box = melt(eeg %>%  
                select(-Label) %>% 
                mutate_each(funs(remove_outiers_and_scale),-Subject,-Active),id.vars=c("Subject","Active"))


### Separate between groups
ggplot(to_box , aes(x=as.factor(Subject),y=as.numeric(value),fill=as.factor(Active) ))+
  geom_boxplot(outlier.shape=NA)+
  facet_wrap(~variable,ncol=1)+
  labs(x="Subject",y="",fill="Active")+
  theme(plot.title = element_text(size=13))+
  scale_fill_manual(values = c("white", "black"))
  
ggsave("../../Figures/berkeley_boxplots.png",width=6,height=8)
	   
## Put columns in the same order as in CMU dataset and store it
dat = eeg[,c(1,10,2,3,4,5,6,7,8,9,12)]

dat %>% mutate(Label=as.numeric(Active)) %>% dplyr::select(-Active) %>% 
  write.csv(.,"../berkeley.csv",row.names=F)


