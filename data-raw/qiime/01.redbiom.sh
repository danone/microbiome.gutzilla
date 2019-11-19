#!/bin/bash

source ./util.sh

if [ -z "${AG_DEBUG}" ]; then
    redbiom search metadata \
        "where qiita_study_id==10317 and sample_type=='Stool'" > ${d}/ag.ids
else
    redbiom search metadata \
        "where qiita_study_id==10317 and sample_type=='Stool'" | head -n 100 > ${d}/ag.ids
fi

redbiom fetch samples \
    --context $redbiom_ctx \
    --output ${d}/ag.biom \
    --from ${d}/ag.ids \
    --resolve-ambiguities most-reads \
    --md5 true

redbiom fetch sample-metadata \
    --context $redbiom_ctx \
    --output ${d}/ag.txt \
    --all-columns \
    --resolve-ambiguities \
    --from ${d}/ag.ids

awk '{ print ">" $2 "\n" $1 }' ${d}/ag.biom.tsv > ${d}/ag.fna
