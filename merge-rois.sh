#!/bin/bash

set -x
#NOTE TO SELF: THIS IS JUST FOR SOPHIA'S PURPOSES. NEED TO GENERALIZE LATER
mkdir -p rois
rois=`jq -r '.rois' config.json`
rois1=`jq -r '.rois1' config.json`
rois2=`jq -r '.rois2' config.json`
roi1outname=`jq -r '.roi1outname' config.json`
roi2outname=`jq -r '.roi2outname' config.json`
rois_type="${rois1} ${rois2}"

rois1_list=($(find ${rois}/ -maxdepth 1 -name "*${rois1}*" -print))
rois2_list=($(find ${rois}/ -maxdepth 1 -name "*${rois2}*" -print))

3dcalc -a ${rois1_list[0]} -prefix ${rois1}ZeroDataset.nii.gz -expr '0'
3dcalc -a ${rois2_list[0]} -prefix ${rois2}ZeroDataset.nii.gz -expr '0'

#merge rois
for TYPES in ${rois_type}
do
	if [[ ${TYPES} == ${rois1} ]]; then
		outname=${roi1outname}
		list=${rois1_list[*]}
	else
		outname=${roi2outname}
		list=${rois2_list[*]}
	fi
	3dTcat -prefix merge_pre_${TYPES}.nii.gz ${TYPES}ZeroDataset.nii.gz `echo ${list[*]}` 
	3dTstat -argmax -prefix ${outname}_nonbyte.nii.gz merge_pre_${TYPES}.nii.gz
	3dcalc -byte -a ${outname}_nonbyte.nii.gz -expr 'a' -prefix ${outname}_allbytes.nii.gz
	3dcalc -a ${outname}_allbytes.nii.gz -expr 'step(a)' -prefix ./rois/ROI${outname}.nii.gz
done

# exit
[ ! -f ./rois/ROI${roi2outname}.nii.gz ] && echo "failed" && exit 1 || echo "complete" && rm -rf *.nii.gz && exit 0
