library(readr)
library(dplyr)
library(reshape2)


DWH_R_STR_SEQ = read_delim("data-raw/DB/formatted data/DWH_R_STR_SEQ.txt", delim="|")


DWH_R_STR_SEQ %>% pull(adp_amp_val) %>% table  %>% sort


DWH_R_STR_SEQ %>%
  select(sub_id,seq_id,thn_val,adp_amp_val,spe_val) -> DWH_R_STR_SEQ_clean


devtools::use_data(DWH_R_STR_SEQ_clean, overwrite = TRUE)


### import diversity indexes

spec_div =
read_delim("data-raw/DB/formatted data/DWH_F_STR_DIV.txt", delim="|", n_max = 1000) %>% spec


attributes(spec_div$cols$seq_id)[["class"]][1] <- "collector_character"
attributes(spec_div$cols$or_res_val)[["class"]][1] <- "collector_character"


DWH_F_STR_DIV = read_delim("data-raw/DB/formatted data/DWH_F_STR_DIV.txt", delim="|", col_types = spec_div)


DWH_F_STR_DIV %>%
  filter(nb_seq_num == 10000) %>%
  select(seq_id,test_cod,or_res_val) -> DWH_F_STR_DIV_clean


devtools::use_data(DWH_F_STR_DIV_clean, overwrite = TRUE)



