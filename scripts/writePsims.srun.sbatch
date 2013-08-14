#!/bin/bash -l

# stripes=58
# #SBATCH --nodes=${stripes}
#SBATCH --nodes=57
#SBATCH --ntasks=57


#SBATCH --account=pi-joshuaelliott
#SBATCH --qos=normal
#SBATCH --partition=sandyb,westmere
#SBATCH --time=4:00:00
#SBATCH --job-name=nldas
#SBATCH --ntasks-per-node=1

##START=$(date)

# for stripe in {1..$((${SLURM_JOB_NUM_NODES}+1));
for stripe in {1..58};
do
    [ ${stripe} -eq 32 ] && continue
    out_file=./log/${SLURM_JOB_NAME}.${stripe}.out  #puts the slurm output into this file
    err_file=./log/${SLURM_JOB_NAME}.${stripe}.err  #error output from slurm goes here
    ## export stripe
    printf "| Running :: %10s | %3s | %10s | %10s |" \
        ${SLURM_JOB_NAME} ${stripe} ${out_file} ${err_file}
    srun  --ntasks=1 --exclusive --output=${out_file} --error=${err_file} scripts/writePsims.r ${stripe}
done


##END=$(date)
# echo "started at $START"
#echo "ended at $END"
