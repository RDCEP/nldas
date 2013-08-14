#!/bin/bash

#SBATCH --job-name=nldas

#SBATCH --workdir=/project/joshuaelliott/nldas

#SBATCH --time=120

#SBATCH --output=log/nldasDownload-%j.out

#SBATCH --nodes=16

#SBATCH --exclusive

# #SBATCH --partition=westmere,sandyb
#SBATCH --constraint=ib

#SBATCH --mail-type=ALL

#SBATCH --mail-user=nbest

# module load openmpi

# sbatch --begin=now+8hours scripts/nldasDownload.sbatch

echo $SLURM_JOB_NODELIST
# mpirun -H $(hostlist --expand -s',' $SLURM_JOB_NODELIST) -n 1 R --slave -f scripts/nldasDownloadMPI.R

mpirun R --slave -f scripts/nldasDownloadMPI.R


