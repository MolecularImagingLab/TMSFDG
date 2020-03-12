#! /bin/bash
subj=$1

space='lh rh'

for s in ${space[@]}; do

	mri_concat --i /group/tuominen/TBS-FDG/subjects/${subj}/rest/TMS10mm-lh.${s}/pr001/TMS10mm-lh/z.nii.gz \
	../subjects/${subj}/rest/TMS10mm-lh.${s}/pr002/TMS10mm-lh/z.nii.gz \
	../subjects/${subj}/rest/TMS10mm-lh.${s}/pr003/TMS10mm-lh/z.nii.gz \
	--mean \
	--o /group/tuominen/TBS-FDG/RSaverages/${subj}/${s}.mean.z.nii.gz
	
done

