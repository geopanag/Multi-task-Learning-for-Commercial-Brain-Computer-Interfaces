Code for paper:

Multi-task learning for commercial Brain Computer Interfaces


Datasets:

https://www.kaggle.com/wanghaohan/eeg-brain-wave-for-confusion
https://www.kaggle.com/berkeley-biosense/synchronized-brainwave-dataset


Folder stucture:

Code,Data,Figures in root
Code-> ( This folder )
Data-> berkeley ( folder with initial data )
    -> cmu             > > 
Data->experiments->folds->train,test ( folders with dataset subsets from cross validation )
				 ->conventional_results ( folder with accuracy tables )
				 ->mtl_results ( folder with predictions-labels paired vectors )
				 ->feature_selection->importance ( feature importance vectors )
							->mtl_weights ( weight vectors )

Run Instructions

Download MALSAR package from http://www.yelab.net/software/MALSAR/ and add it to this folder. 
Install MALSAR package. 
Install Libraries used in R: "dplyr","reshape2","ggplot2","gridExtra","xtable","tidyr","reshape2","ggplot2","neuralnet","randomForest","xgboost","Matrix","data.table","e1071","caret","plyr"
The code pipeline to reproduce the analysis follows the order of the number in the script's title. If two scripts have the same number, they can be run simultaneously. (matlab scripts have e1,e2.. instead of 1,2 ..)

