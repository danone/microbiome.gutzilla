#!/bin/bash

source ./util.sh

wget \
    -O ${d}/newbloom.all.fna \
    https://raw.githubusercontent.com/knightlab-analyses/bloom-analyses/master/data/newbloom.all.fna

for s in $(grep -v "^>" ${d}/newbloom.all.fna | cut -c 1-${trim_length}); do
    h=$(echo -n $s | md5sum | awk '{ print $1 }')
    echo -e "${h} ${s}"
done | sort - | uniq | awk '{ print ">" $1 "\n" $2 }' > ${d}/newbloom.all.${trim_length}nt.fna

qiime tools import \
    --input-path ${d}/ag.fna \
    --output-path ${d}/ag.fna.qza \
    --type FeatureData[Sequence]

qiime tools import \
    --input-path ${d}/ag.biom \
    --output-path ${d}/ag.biom.qza \
    --type FeatureTable[Frequency]

qiime tools import \
    --input-path ${d}/newbloom.all.${trim_length}nt.fna \
    --output-path ${d}/blooms.fna.qza \
    --type FeatureData[Sequence]
