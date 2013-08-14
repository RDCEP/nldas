#!/bin/bash

#SBATCH --job-name=nldas

#SBATCH --workdir=/project/joshuaelliott/nldas

#SBATCH --time=478

#SBATCH --output=log/nldasDownload-%j.out

#SBATCH --nodes=1

#SBATCH --exclusive

#SBATCH --partition=westmere,sandyb

#SBATCH --mail-type=ALL

#SBATCH --mail-user=nbest

# sbatch --begin=now+8hours scripts/nldasDownload.sbatch
R --slave -f scripts/nldasDownload.R


