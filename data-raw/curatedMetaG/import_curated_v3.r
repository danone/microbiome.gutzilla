library(curatedMetagenomicsData)
library(dplyr)
library(phyloseq)

curatedStudy <-
    filter(sampleMetadata, number_reads >= 5000000) %>%
    #filter(!is.na(alcohol)) %>%
    filter(body_site == "stool") %>%
	filter(study_name != "LeChatelierE_2013") %>%
    select(where(~ !all(is.na(.x)))) %>%
    returnSamples("relative_abundance", counts = TRUE)

	
curatedStudy_phylo <- makePhyloseqFromTreeSummarizedExperiment(curatedStudy, abund_values = "relative_abundance")	

OTU = otu_table(curatedStudy_phylo)
TAX = tax_table(curatedStudy_phylo)

save(OTU,TAX, sampleMetadata, file="curated_v3_otu_tax.rda")

	

	
