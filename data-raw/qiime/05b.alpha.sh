#!/bin/bash

source ./util.sh

mkdir -p ${d}/alpha

qiime diversity alpha \
    --i-table ${d}/ag.biom.nobloom.min2.min1k.sepp.even1k.qza \
    --p-metric shannon \
    --o-alpha-diversity ${d}/alpha/shannon.qza

qiime diversity alpha-phylogenetic-alt \
    --i-table ${d}/ag.biom.nobloom.min2.min1k.sepp.even1k.qza \
    --i-phylogeny ${d}/ag.nobloom.min2.min1k.sepp.gg138.tree.qza \
    --p-metric faith_pd \
    --o-alpha-diversity ${d}/alpha/faith_pd.qza
