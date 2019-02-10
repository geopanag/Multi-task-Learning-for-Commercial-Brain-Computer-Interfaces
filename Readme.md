
# Multi-task Learning for Commercial Brain Computer Interfaces

Code to reproduce the results of [Multi-task Learning for Commercial Brain Computer Interfaces](https://ieeexplore.ieee.org/document/8251271)  <br />


### Folder Structure
Root Folders :Code,Data,Figures <br />
Code-> ( Fill it with this code ) <br />
Data-> berkeley ( fill it with the data found in https://www.kaggle.com/berkeley-biosense/synchronized-brainwave-dataset) <br />
Data->cmu       ( fill it with the data found in  https://www.kaggle.com/wanghaohan/eeg-brain-wave-for-confusion) <br />
Data->experiments->train, test          (will be filled with dataset subsets from cross validation ) <br />
Data->experiments ->conventional_results (will be filled with accuracy tables ) <br />
Data->experiments->mtl_results 			(will be filled with predictions-labels paired vectors ) <br />
Data->experiments->feature_selection->importance (will be filled with feature importance vectors ) <br />
Data->experiments->feature_selection->mtl_weights (will be filled with weight vectors ) <br />

Run Instructions<br />

### Requirements
R libraries: "dplyr","reshape2","ggplot2","gridExtra","xtable","tidyr","reshape2","ggplot2","neuralnet","randomForest","xgboost","Matrix","data.table","e1071","caret","plyr"<br />
MALSAR package from http://www.yelab.net/software/MALSAR/

### Run Instructions
Each script can be run individually, following the order of the number in the script's title  (matlab scripts have e1,e2.. instead of 1,2 ..). If two scripts have the same number, they can be run simultaneously.
The MALSAR package needs to be installed at the current directory.
