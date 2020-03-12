#! /bin/bash
  
if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` <subjectname>"
  echo "This script will run individual with session resting state analyses for each run separately."
  echo "Make sure you have defined SUBJECTS_DIR variable and run the fsl_motion_outliers"
  exit 0
fi

subj=$1
labels='TMS10mm-lh.label  TMS20mm-lh.label' 
parentdir="$(dirname "$SUBJECTS_DIR")"
space='lh rh mni305' 

## preprocess the data 
preproc-sess -s ${subj} -fwhm 5 -surface fsaverage lhrh -mni305-2mm -sliceorder siemens -per-run -fsd rest -d ${parentdir}/subjects/

## individualize seeds: 1) fsaverage to individual surface 2) individual surface to volume 
for l in ${labels[@]}; do
	mri_label2label --srclabel ${parentdir}/seeds/${l} --srcsubject fsaverage --trglabel ind.${l} --trgsubject ${subj} --regmethod surface --hemi lh		
	mri_label2vol --subject ${subj} --label $SUBJECTS_DIR/${subj}/label/ind.${l} --o $SUBJECTS_DIR/${subj}/mri/ind.${l::-6}.mgz --proj frac 0 1 0.01 --hemi lh --temp ${parentdir}/subjects/${subj}/rest/001/f.nii --fill-ribbon --reg ${parentdir}/subjects/${subj}/rest/register.dof6.lta 
done

## get seed time courses for 1) white matter, 2) csf, 3) both seeds  
fcseed-sess -s ${subj} -cfg ${parentdir}/seeds/wm.config -d ${parentdir}/subjects -overwrite
fcseed-sess -s ${subj} -cfg ${parentdir}/seeds/vcsf.config -d ${parentdir}/subjects -overwrite

for l in ${labels[@]}; do
	fcseed-sess -s ${subj} -make-mask -d ${parentdir}/subjects -cfg ${parentdir}/seeds/${l::-6}.config -overwrite
done

## do resting state analysis connectivity analysis for each run separately  
cd ${parentdir}/mkanalysis
for l in ${labels[@]}; do
	for s in ${space[@]}; do	
		selxavg3-sess -s ${subj} -a ${l::-6}.${s} -d ${parentdir}/subjects -run-wise -no-con-ok
	done
done

## average z-scores across the 3 runs ... at this point it's unclear if -run-wise flag is necessary or not, if I continue without will I get the same point estimate as from averaging? 


