#!/bin/bash

#SBATCH --job-name=verify

#SBATCH --workdir=/project/joshuaelliott/nldas

#SBATCH --time=240

#SBATCH --output=log/verifyChecksums-%j.out

#SBATCH --nodes=10

#SBATCH --exclusive

#SBATCH --constraint=ib

#SBATCH --mail-type=ALL

#SBATCH --mail-user=nbest

# module load openmpi

# sbatch --begin=now+8hours scripts/nldasDownload.sbatch

mpirun R --slave -f scripts/verifyChecksums.R


