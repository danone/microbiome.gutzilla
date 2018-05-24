library(readr)
library(dplyr)


read_delim("data-raw/DB/formatted data/DWH_R_STR_DM.txt", delim="|") %>%
select(-contains("cmp"),-contains("arm"),-contains("dm"),-contains("val_"),
       -ageu_val, -study_id, -domain, -lod_dat, -unq_seq_001) -> DWH_R_STR_DM_clean

devtools::use_data(DWH_R_STR_DM_clean, overwrite = TRUE)
