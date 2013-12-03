
PATH=~/local/cctools/bin:$PATH
makeflow -c
slurm_submit_workers --cores 0 -p "--time=120" midway-login2 9123 8
makeflow -Tworkqueue-sharedfs
