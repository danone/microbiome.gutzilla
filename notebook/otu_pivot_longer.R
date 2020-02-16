library(dplyr)

load(file="../otu.rda")

otu_longer_1 =
  otu[1:5000] %>%
  #select(-taxonomy) %>%
  mutate_at(-1, ~na_if(.,0)) %>%
  tidyr::pivot_longer(-`#OTU ID`, names_to = "sample_id", values_to = "count",    values_drop_na = TRUE)

saveRDS(otu_longer_1, file = "otu_longer_1.rds")

otu_longer_2 =
  otu[c(1,5001:10000)] %>%
  #select(-taxonomy) %>%
  mutate_at(-1, ~na_if(.,0)) %>%
  tidyr::pivot_longer(-`#OTU ID`, names_to = "sample_id", values_to = "count",    values_drop_na = TRUE)

saveRDS(otu_longer_2, file = "otu_longer_2.rds")

otu_longer_3 =
  otu[c(1,10001:15000)] %>%
  #select(-taxonomy) %>%
  mutate_at(-1, ~na_if(.,0)) %>%
  tidyr::pivot_longer(-`#OTU ID`, names_to = "sample_id", values_to = "count",    values_drop_na = TRUE)

saveRDS(otu_longer_3, file = "otu_longer_3.rds")

last_sample=dim(otu)[2]-1

otu_longer_4 =
  otu[c(1,15001:last_sample)] %>%
  #select(-taxonomy) %>%
  mutate_at(-1, ~na_if(.,0)) %>%
  tidyr::pivot_longer(-`#OTU ID`, names_to = "sample_id", values_to = "count",    values_drop_na = TRUE)

saveRDS(otu_longer_4, file = "otu_longer_4.rds")


otu_longer_all = rbind(otu_longer_1,otu_longer_2,otu_longer_3,otu_longer_4)

saveRDS(otu_longer_all, file = "otu_longer_all.rds")

