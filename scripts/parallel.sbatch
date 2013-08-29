#!/bin/sh

#SBATCH --ntasks=64
#SBATCH --partition=sandyb
#SBATCH --constraint ib
#SBATCH --exclusive
#SBATCH --time 12:00:00

module load parallel

# the --exclusive to srun make srun use distinct CPUs for each job step
# -N1 = 1 node
# -n1 = 1 task per node
# -c 4 = 4 CPUs per task
srun="srun --exclusive -N1 -n1 -c 16"

# -j is the number of tasks parallel runs so we set it to $SLURM_NTASKS
# --joblog makes parallel create a log of tasks that it has already run
# --resume makes parallel use the joblog to resume from where it has left off
# the combination of --joblog and --resume allow jobs to be resubmitted if
# necessary and continue from where they left off
parallel="parallel -j $SLURM_NTASKS --joblog runtask.log --resume"

# this runs the parallel command we want
# in this case, we are running a script named runtask
# srun --exclusive -N1 -n1 -c 4 ./runtask i > runtask.i
$parallel "$srun --error=log/writePsims.{1}.err --output=log/writePsims.{1}.out scripts/writePsims.r {1}" ::: {1..116}
