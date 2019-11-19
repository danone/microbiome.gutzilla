#!/bin/bash

source ./util.sh

mkdir -p ${d}/beta/pcoa
mkdir -p ${d}/beta/emp

for ar in ${d}/beta/*.qza
do
    name=$(basename ${ar} .qza)
    qiime diversity pcoa \
        --i-distance-matrix ${ar} \
        --o-pcoa ${d}/beta/pcoa/${name}.qza \
        --p-number-of-dimensions 10

    qiime emperor plot \
        --i-pcoa ${d}/beta/pcoa/${name}.qza \
        --m-metadata-file ${d}/ag.txt \
        --o-visualization ${d}/beta/emp/${name}.qzv
done
