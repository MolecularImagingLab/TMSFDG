#! /bin/bash

# this command has two inputs:
# 	- input 1 is the subject name
# 	- input 2 is the text file containing the target coordinates. eg. -38 44 26 separated by spaces. 
# 
# output is a text file containing the warped target coordinates in the folder where you had the T1. 
# you need to have fsl to run this script. 

subj=$1
target=$2

parentdir="$(dirname "$SUBJECTS_DIR")"
pd=${parentdir}/subjects/${subj}/anat/001/


T1=${pd}/T1.nii
swaped=${pd}/T1.swaped.nii.gz
betted=${pd}/T1.swaped.betted.nii.gz
warped=${pd}/T1.swaped.warped.nii.gz

fslswapdim $T1 z -x -y ${swaped}
bet ${swaped} ${betted}
flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii -in ${betted} -omat ${pd}/my_affine_transf.mat
fnirt --ref=MNI152_T1_2mm.nii --in=${swaped} --aff=${pd}/my_affine_transf.mat --cout=${pd}/my_nonlinear_transf --config=T1_2_MNI152_2mm --refmask=MNI152_T1_2mm_brain_mask_dil.nii 
applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=${swaped} --warp=${pd}/my_nonlinear_transf.nii.gz --out=${warped}
std2imgcoord -img ${swaped} -std ${FSLDIR}/data/standard/MNI152_T1_2mm -warp ${pd}/my_nonlinear_transf.nii.gz ${target} > ${pd}/warped_target.txt

