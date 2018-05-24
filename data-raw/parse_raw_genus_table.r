library(readr)
library(reshape2)
library(dplyr)


otu_table_L6 = read.table("data-raw/RAW/raw data/2017-04/Taxa/100nt/otu_table_L6.txt", skip=1, comment.char = "", sep="\t", dec=".",
                          header=TRUE, check.names = FALSE, stringsAsFactors = FALSE)

otu_table_L6 =
  otu_table_L6 %>% as_tibble()



otu_table_L6 %>%
  melt(id.vars=c("#OTU ID")) %>%
  filter(value != 0) %>%
  mutate(`#OTU ID` = gsub("k__|p__|c__|o__|f__|g__","",`#OTU ID`)) %>%
  tidyr::separate(`#OTU ID`,
                  into=c("kig_val","phy_val","cls_val","ord_val","fam_val","gen_val"),
                  sep=";") -> otu_table_L6_clean

otu_table_L6_clean =
  otu_table_L6_clean %>% rename(seq_id = "variable")



compare = merge(otu_table_L6_clean, DWH_F_STR_TXN_clean, by=c("seq_id","kig_val","phy_val","cls_val","ord_val","fam_val","gen_val"))

compare %>% pull(value) %>% summary










