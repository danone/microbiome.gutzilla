#!/bin/bash

source ./util.sh

#if [ -z "${AG_DEBUG}" ]; then
    redbiom search metadata \
        "where qiita_study_id==10317 and sample_type=='Stool'" > ${d}/ag.ids
#else
    #redbiom search metadata \
     #   "where qiita_study_id==10317 and sample_type=='Stool'" | head -n 100 > ${d}/ag.ids
#fi

    redbiom search metadata \
        "where qiita_study_id==10317 and  age_cat in ('20s','30s','40s','50s','60s','70') " > ${d}/ag.adults.ids

# merge adult and stool ids with one liner R script
Rscript -e "path <- commandArgs()[7]; toto=readLines(paste0(path,'/ag.ids'));titi=readLines(paste0(path,'/ag.adults.ids')); writeLines(intersect(toto,titi))" $d > ${d}/ag.ids

# this can be done with bash sort | uniq -d but sort migth be too slow compared to R intersect

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
