#!/bin/sh

module load parallel
parallel \
    --jobs $SLURM_NTASKS \
    -I '${url}' \
    --keep-order \
    --retries 10 \
    'srun --exclusive -N1 -n1 \
      wget \
          --no-host-directories \
          --cut-dirs=3 \
          --directory-prefix=data \
          --recursive \
          --quiet \
          --retry-connrefused \
          --timestamping \
          ${url};
    find data/$(echo -n ${url} | cut -d/ -f7-9) \
        -name $(echo -n ${url} | cut -d/ -f10)  | 
    tee data/parallelOutput |
    xargs scripts/nldasGrbChecksum.r' \
    :::: data/nldasDataUrls
