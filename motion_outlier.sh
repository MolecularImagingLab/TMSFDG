#!/bin/bash

## Motion outlior command 

subj=$1

list='001 002 003'

for r in ${list[@]}; do
	fsl_motion_outliers -i ../subjects/$subj/rest/$r/f.nii \
	-o ../subjects/$subj/rest/$r/mc.output \
	-p ../subjects/$subj/rest/$r/mc.plot \
	-s ../subjects/$subj/rest/$r/mc.fd --fd 
done
