#!/bin/bash

set -x
set -e

# set up TMP folder to user home
if [[ -O /home/$USER/tmp && -d /home/$USER/tmp ]]; then
        TMPDIR=/home/$USER/tmp
else
        # You may wish to remove this line, it is there in case
        # a user has put a file 'tmp' in there directory or a
        rm -rf /home/$USER/tmp 2> /dev/null
        mkdir -p /home/$USER/tmp
        TMPDIR=$(mktemp -d /home/$USER/tmp/XXXX)
fi

TMP=$TMPDIR
TEMP=$TMPDIR

export TMPDIR TMP TEMP


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


