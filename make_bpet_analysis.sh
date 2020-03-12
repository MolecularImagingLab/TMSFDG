## define variables 
# enter subject without decimal
subj=$1
parentdir="$(dirname "$SUBJECTS_DIR")"
pdir1=${parentdir}/subjects/${subj}.1/pet/001/
pdir2=${parentdir}/subjects/${subj}.2/pet/001/

## Ensure that a subject ID was provided as first argument and data exists 

if [ -z $subj ] ; then 
	echo "----------------------------------------------------------------------------------------------------------------
	Error:  No subject ID was provided. 
	Please enter a valid subject ID as the first argument, e.g., 'TBSFDG001'.
	----------------------------------------------------------------------------------------------------------------"
	exit 1 
elif [ ! -f ${parentdir}/subjects/${subj}.1/pet/001/p.nii ] || [ ! -f ${parentdir}/subjects/${subj}.2/pet/001/p.nii ] ; then 
	echo "----------------------------------------------------------------------------------------------------------------
	Error:  The p.nii does not exist for ${subj}.1 or ${subj}.2. 
	Please enter a valid subject ID as the first argument, e.g., 'TBSFDG001'.
	Subject must have the following files: ${parentdir}/subjects/${subj}.1/pet/001/p.nii and 
	${parentdir}/subjects/${subj}.1/pet/001/p.nii
	----------------------------------------------------------------------------------------------------------------"
	exit 2
elif [[ ! -d $SUBJECTS_DIR/${subj}.1 ]] || [[ ! -d $SUBJECTS_DIR/${subj}.2 ]] ; then 
	echo "----------------------------------------------------------------------------------------------------------------
	Error:  The subject ${subj}.1 or ${subj}.2 does not exist in the SUBJECTS_DIR: 
	$SUBJECTS_DIR. 
	Please enter a valid subject ID as the first argument, e.g., 'TBSFDG001'.
	Subject must run recon-all to the subject first: e.g. ./make_recon-all.sh ${subj}.1 
	----------------------------------------------------------------------------------------------------------------"
	exit 3

else 
	echo "Brain PET Analysis is now running for ${subj}." 
fi


####### do preprocessing of both PET scans 

./preprocFDGPET.sh $pdir1/p.nii $subj.1 &
./preprocFDGPET.sh $pdir2/p.nii $subj.2

####### calculate ROI values, normalize and smooth #############

## get ROI values 
mri_segstats --i ${pdir1}SUVR.in.anat.nii.gz --seg $SUBJECTS_DIR/${subj}.1/mri/aparc+aseg.mgz --sum ${pdir1}/${subj}.1.PET.summary.ROI.stats.dat --excludeid 0 &
mri_segstats --i ${pdir2}SUVR.in.anat.nii.gz --seg $SUBJECTS_DIR/${subj}.2/mri/aparc+aseg.mgz --sum ${pdir2}/${subj}.2.PET.summary.ROI.stats.dat --excludeid 0

## normalize to surface
echo "---------------------------------------------------------------------------------------------------------------- 
Preprocessing finished for ${subj}.
----------------------------------------------------------------------------------------------------------------" 

exit 0 


