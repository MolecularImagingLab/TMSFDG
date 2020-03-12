subj=$1
parentdir="$(dirname "$SUBJECTS_DIR")"
recon-all -i $parentdir/subjects/${subj}/anat/001/T1.nii -s ${subj} -all -parallel

