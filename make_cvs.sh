#! /bin/bash

## mri cvs command 
subjects=('TBSFDG001.1' 'TBSFDG001.2' 'TBSFDG002.1' 'TBSFDG002.2' 'TBSFDG004.1' 'TBSFDG004.2' 'TBSFDG005.1' 'TBSFDG005.2' 'TBSFDG006.1' 'TBSFDG006.2' 'TBSFDG007.1' 'TBSFDG007.2' 'TBSFDG008.1' 'TBSFDG008.2' 'TBSFDG009.1' 'TBSFDG009.2')
# loop over subjects 
for s in ${subjects[@]}; do
	mri_cvs_register --mov ${s} --mni --openmp 8 &
done
