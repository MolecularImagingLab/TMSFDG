#! /bin/bash

FstPET_T1=$1
SndPET_T1=$2
base=${FstPET_T1::-2}_base
recon-all -base $base -tp $FstPET_T1 -tp $SndPET_T1 -all
recon-all -long $FstPET_T1 $base -all
recon-all -long $SndPET_T1 $base -all
