#! /bin/bash

## preproc FDG PET data

pet=$1
subject=$2

pdir=$( dirname $pet )
p=$( basename $pet )

echo "---------------------------------------------------------------------------------------------------------------- 
Doing motion correction for ${pet}.
----------------------------------------------------------------------------------------------------------------"

# motion correct 
mcflirt -in $pet -refvol 0 -out $pdir/mc_${p} # out = mc_p1.nii 

echo "---------------------------------------------------------------------------------------------------------------- 
Summing up frames of $pdir/mc_${p}.
----------------------------------------------------------------------------------------------------------------"

# sum
mri_concat $pdir/mc_${p}.gz --sum --o $pdir/sum_mc_${p}.gz # out = sum_mc_p1.nii.gz

echo "---------------------------------------------------------------------------------------------------------------- 
Reslicing $pdir/sum_mc_${p}.gz.
----------------------------------------------------------------------------------------------------------------" 

# reslice 
mri_convert $pdir/sum_mc_${p}.gz -vs 2 2 2 $pdir/rs_sum_mc_${p}.gz --force_ras_good # out = rs_sum_mc_p1.nii.gz

echo "---------------------------------------------------------------------------------------------------------------- 
Coregistering $pdir/rs_sum_mc_${p}.gz to ${subject}.
----------------------------------------------------------------------------------------------------------------" 

# coregister to T1
mri_coreg --s ${subject} --targ $SUBJECTS_DIR/${subject}/mri/brain.mgz --no-ref-mask --mov $pdir/rs_sum_mc_${p}.gz --reg $pdir/p2mri1.reg.lta --dof 9 --threads 3 # out = p2mri1.reg.lta

# move to T1
mri_vol2vol --reg $pdir/p2mri1.reg.lta --mov $pdir/rs_sum_mc_${p}.gz --fstarg --o $pdir/in-anat-${p}.gz  # out = in-anat-p.nii.gz

echo "---------------------------------------------------------------------------------------------------------------- 
Calculating SUVR from $pdir/rs_sum_mc_${p}.gz.
----------------------------------------------------------------------------------------------------------------" 
mri_convert ${SUBJECTS_DIR}/${subject}/mri/aparc+aseg.mgz ${SUBJECTS_DIR}/${subject}/mri/aparc+aseg.nii.gz
./make_mask.sh ${SUBJECTS_DIR}/${subject}/mri/aparc+aseg.nii.gz 
fslmaths ${SUBJECTS_DIR}/${subject}/mri/aparc+aseg.nii.gz -bin ${SUBJECTS_DIR}/${subject}/mri/aparc+aseg_bin.nii.gz 
fslmaths ${SUBJECTS_DIR}/${subject}/mri/aparc+aseg_bin.nii.gz -sub ${SUBJECTS_DIR}/${subject}/mri/CSF_mask.nii.gz ${SUBJECTS_DIR}/${subject}/mri/wmgm_mask.nii.gz
mask=${SUBJECTS_DIR}/${subject}/mri/wmgm_mask.nii.gz
fslstats $pdir/in-anat-${p}.gz -k $mask -M > ${pdir}/wmgm_mean_activity
R=$( cat ${pdir}/wmgm_mean_activity ) 
fslmaths $pdir/rs_sum_mc_${p}.gz -div $R ${pdir}/SUVR.nii.gz
fslmaths $pdir/in-anat-${p}.gz -div $R ${pdir}/SUVR.in.anat.nii.gz

echo "---------------------------------------------------------------------------------------------------------------- 
Registering ${subject} to MNI152 
----------------------------------------------------------------------------------------------------------------" 

# create a map to MNI152
mni152reg --s ${subject} 

echo "---------------------------------------------------------------------------------------------------------------- 
Normalizing and smoothing ${pdir}/SUVR.nii.gz.
----------------------------------------------------------------------------------------------------------------" 

# move SUVR to MNI152
mri_vol2vol --mov $pdir/SUVR.nii.gz --reg $pdir/p2mri1.reg.lta --mni152reg --talres 2 --o $pdir/SUVR.mni152.2mm.sm00.nii.gz #out = SUVR1.mni152.2mm.sm00.nii.gz

# smooth SUVRs
fslmaths $pdir/SUVR.mni152.2mm.sm00.nii.gz -s 5 $pdir/SUVR.mni152.2mm.sm05.nii.gz # out = SUVR1.mni152.2mm.sm05.nii.gz 

# move to fsaverage space 
mri_vol2surf --mov ${pdir}/SUVR.nii.gz --reg  $pdir/p2mri1.reg.lta --hemi lh --projfrac 0.5 --o ${pdir}/lh.SUVR.fsaverage.sm00.nii.gz --cortex --trgsubject fsaverage 
mri_vol2surf --mov ${pdir}/SUVR.nii.gz --reg  $pdir/p2mri1.reg.lta --hemi rh --projfrac 0.5 --o ${pdir}/rh.SUVR.fsaverage.sm00.nii.gz --cortex --trgsubject fsaverage 

# smooth fsaverage SUVR
mris_fwhm --smooth-only --i ${pdir}/lh.SUVR.fsaverage.sm00.nii.gz --fwhm 5 --o ${pdir}/lh.SUVR.fsaverage.sm05.nii.gz --cortex --s fsaverage --hemi lh 
mris_fwhm --smooth-only --i ${pdir}/rh.SUVR.fsaverage.sm00.nii.gz --fwhm 5 --o ${pdir}/rh.SUVR.fsaverage.sm05.nii.gz --cortex --s fsaverage --hemi rh 








