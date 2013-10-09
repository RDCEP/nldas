#!/bin/bash -l

#SBATCH --account=pi-joshuaelliott
#SBATCH --qos=normal
# #SBATCH --partition=sandyb,westmere
# #SBATCH --partition=bigmem,amd
#SBATCH --constraint=ib
#SBATCH --time=60
#SBATCH --exclusive

START=$(date)
scripts/writePsims.r ${stripe}
END=$(date)
echo "started at $START"
echo "ended at $END"
