#!/bin/bash

source ./util.sh

qiime coordinates draw-map \
    --m-metadata-file ${d}/ag.denotes-single-subject-sample.txt \
    --
