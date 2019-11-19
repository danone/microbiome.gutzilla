#!/bin/bash

source ./util.sh

mkdir -p ${d}/beta

qiime diversity beta-phylogenetic \
    --i-table ${d}/ag.biom.nobloom.min2.min1k.sepp.even1k.qza \
    --i-phylogeny ${d}/ag.nobloom.min2.min1k.sepp.gg138.tree.qza \
    --p-n-jobs ${nprocs} \
    --p-metric unweighted_unifrac \
    --p-bypass-tips \
    --o-distance-matrix ${d}/beta/unweighted_unifrac.qza

qiime diversity beta-phylogenetic \
    --i-table ${d}/ag.biom.nobloom.min2.min1k.sepp.even1k.qza \
    --i-phylogeny ${d}/ag.nobloom.min2.min1k.sepp.gg138.tree.qza \
    --p-n-jobs ${nprocs} \
    --p-metric weighted_normalized_unifrac \
    --p-bypass-tips \
    --o-distance-matrix ${d}/beta/weighted_normalized_unifrac.qza
