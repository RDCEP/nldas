#!/bin/sh

sbatch \
    --ntasks=32 \
    --exclusive \
    scripts/parallelWget.sh
