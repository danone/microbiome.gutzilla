#!/bin/bash

source ./util.sh

qiime feature-table rarefy \
    --i-table ${d}/ag.biom.nobloom.min2.min1k.sepp.qza \
    --p-sampling-depth 1000 \
    --o-rarefied-table ${d}/ag.biom.nobloom.min2.min1k.sepp.even1k.qza
