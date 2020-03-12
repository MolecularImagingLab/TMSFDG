#!/usr/bin/env Rscript
## Motion outlior command 
#fsl_motion_outliers -i f.nii -o mc.output -p mc.plot -s mc.fd --fd 

## This script will convert fsl_motion_outlier output into seconds. Make sure you run the motion_outlier command first. Good Luck!! 

## inputs 

args = commandArgs(trailingOnly=TRUE)

if (length(args)!=1) {
  stop('\n', '\n', "Please  supply two arguments: the participant ID & run", '\n',
       paste('---------------------------------------------------------------------------------------------------------'), 
       call. = TRUE)
}
subj <- args[1]

## define paths 
project.dir <- dirname(Sys.getenv("SUBJECTS_DIR"))

runs = c('001', '002', '003')
for (run in runs){
  input.file <- file.path(project.dir, 'subjects', subj, 'rest', run, 'mc.output')
  out.file <- file.path(project.dir, 'subjects', subj, 'rest', run, 'tpef.rs')
  
  ## read data 
  data <- read.csv(input.file, sep="",header=F)
  numberCols = ncol(data)
  for (i in 1:numberCols){
  	t<-which(data[,i]==1)
  	data[t-1,i] = 1
  	data[t+1,i] = 1
  }
  	
  ## calculate seconds 
  vector <-as.vector(rowSums(data))
  timepoints <- which(vector >= 1)
  timepoints <- timepoints -1 
  tpef<-timepoints * 2.3
  
  ## remove all time points after 209
  exclude = 209*2.3
  tpef <- tpef[tpef<exclude]
  
  # write file
  sink(out.file)
  cat(tpef, sep=" ")
  cat("\n")
  sink()
}