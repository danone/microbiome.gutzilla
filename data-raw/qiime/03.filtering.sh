#!/bin/bash

source ./util.sh

qiime feature-table filter-features \
    --i-table ${d}/ag.biom.qza \
    --m-metadata-file ${d}/blooms.fna.qza \
    --p-exclude-ids \
    --o-filtered-table ${d}/ag.biom.nobloom.qza

qiime feature-table filter-features \
    --i-table ${d}/ag.biom.nobloom.qza \
    --p-min-frequency 2 \
    --o-filtered-table ${d}/ag.biom.nobloom.min2.qza

qiime feature-table filter-samples \
    --i-table ${d}/ag.biom.nobloom.min2.qza \
    --p-min-frequency 1000 \
    --o-filtered-table ${d}/ag.biom.nobloom.min2.min1k.qza

qiime feature-table filter-seqs \
    --i-table ${d}/ag.biom.nobloom.min2.min1k.qza \
    --i-data ${d}/ag.fna.qza \
    --o-filtered-data ${d}/ag.fna.nobloom.min2.min1k.qza
