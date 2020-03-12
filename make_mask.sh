#! /bin/bash
target=$1 

targ_dir=$(dirname $target)
temp=${targ_dir}/temp
mkdir ${temp}

fslmaths $target -thr 24 -uthr 24 -bin ${temp}/CSF_mask.nii.gz

remove=(4 5 14 15 43 44 72 73)
for r in ${remove[@]};do
fslmaths $target -thr $r -uthr $r -bin ${temp}/${r}.nii.gz
fslmaths ${temp}/CSF_mask.nii.gz -add ${temp}/${r}.nii.gz -bin ${temp}/CSF_mask.nii.gz 

done

cp ${temp}/CSF_mask.nii.gz $targ_dir
rm -r ${temp}
