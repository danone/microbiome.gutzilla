#!/bin/bash

set -x
set -e

# set up file system
export HDF5_USE_FILE_LOCKING=FALSE

#source activate qiime2-2019.10
source /opt/anaconda3/bin/activate qiime2-2019.10


# NOTE: these need to be consistent!
redbiom_ctx=Deblur-Illumina-16S-V4-100nt-fbc5b2
trim_length=100

function base () {
    echo "$(readlink current)"
}

d="$(base)"

if [ ! -d "${d}" ]; then
    >&2 echo "${d} does not exist"
    exit 1
fi

#if [ -z "$PBS_NUM_PPN" ]; then
#    nprocs=1
#else
#    nprocs=$PBS_NUM_PPN
#fi

nprocs=24


