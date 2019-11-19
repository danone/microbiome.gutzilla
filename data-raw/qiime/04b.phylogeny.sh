#!/bin/bash

source ./util.sh

wget \
    -O ${d}/sepp-refs-gg-13-8.qza \
    https://data.qiime2.org/2019.10/common/sepp-refs-gg-13-8.qza

qiime fragment-insertion sepp \
    --i-representative-sequences ${d}/ag.fna.nobloom.min2.min1k.qza \
    --i-reference-database ${d}/sepp-refs-gg-13-8.qza \
    --o-placements ${d}/ag.nobloom.min2.min1k.sepp.gg138.placements.qza \
    --o-tree ${d}/ag.nobloom.min2.min1k.sepp.gg138.tree.qza \
    --p-threads ${nprocs}

qiime fragment-insertion filter-features \
    --i-table ${d}/ag.biom.nobloom.min2.min1k.qza \
    --i-tree ${d}/ag.nobloom.min2.min1k.sepp.gg138.tree.qza \
    --o-filtered-table ${d}/ag.biom.nobloom.min2.min1k.sepp.qza \
    --o-removed-table ${d}/ag.biom.nobloom.min2.min1k.nosepp.qza
