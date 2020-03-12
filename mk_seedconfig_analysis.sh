#! /bin/bash
## make config for seed based analysis
labels='TMS10mm-lh.label  TMS20mm-lh.label' 
parentdir="$(dirname "$SUBJECTS_DIR")"

# config for white matter & CSF
fcseed-config -wm -fcname wm.dat -fsd rest -pca -cfg ${parentdir}/seeds/wm.config -overwrite
fcseed-config -vcsf -fcname vcsf.dat -fsd rest -pca -cfg ${parentdir}/seeds/vcsf.config -overwrite

for l in ${labels[@]}; do

	# config for each seed
	fcseed-config -segid 1 -seg ind.${l::-6}.mgz -fcname ${l::-6}.dat -fsd rest -mean -cfg ${parentdir}/seeds/${l::-6}.config -fillthresh 0.5 -overwrite

	# analyses for each seed

	mkanalysis-sess -analysis ${parentdir}/mkanalysis/${l::-6}.lh -surface fsaverage lh -fwhm 5 -notask -taskreg ${l::-6}.dat 1 -nuisreg vcsf.dat 5 -nuisreg wm.dat 5 -nuisreg global.waveform.dat 1 -mcextreg -polyfit 5 -fsd rest -per-run -TR 2.3 -force

	mkanalysis-sess -analysis ${parentdir}/mkanalysis/${l::-6}.rh -surface fsaverage rh -fwhm 5 -notask -taskreg ${l::-6}.dat 1 -nuisreg vcsf.dat 5 -nuisreg wm.dat 5 -nuisreg global.waveform.dat 1 -mcextreg -polyfit 5 -fsd rest -per-run -TR 2.3 -force

	mkanalysis-sess -analysis ${parentdir}/mkanalysis/${l::-6}.mni305 -mni305 -fwhm 5 -notask -taskreg ${l::-6}.dat 1 -nuisreg vcsf.dat 5 -nuisreg wm.dat 5 -nuisreg global.waveform.dat 1 -tpef tpef.rs -mcextreg -polyfit 5 -fsd rest -per-run -TR 2.3 -force

done
