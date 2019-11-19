#!/bin/bash

source ./util.sh

wget \
      -O ${d}/gg-13-8-99-515-806-nb-classifier.qza \
        "https://data.qiime2.org/2019.10/common/gg-13-8-99-515-806-nb-classifier.qza"

qiime feature-classifier classify-sklearn \
    --i-classifier ${d}/gg-13-8-99-515-806-nb-classifier.qza \
    --i-reads ${d}/ag.fna.nobloom.min2.min1k.qza \
    --p-n-jobs ${nprocs} \
    --o-classification ${d}/ag.fna.nobloom.min2.min1k.taxonomy.qza
