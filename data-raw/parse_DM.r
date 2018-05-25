library(readr)
library(dplyr)


read_delim("data-raw/DB/formatted data/DWH_R_STR_DM.txt", delim="|") %>%
select(-contains("cmp"),-contains("arm"),-contains("dm"),-contains("val_"),
       -ageu_val, -study_id, -domain, -lod_dat, -unq_seq_001) -> DWH_R_STR_DM_clean

devtools::use_data(DWH_R_STR_DM_clean, overwrite = TRUE)



read_delim("data-raw/DB/formatted data/DTM_F_STR_VS.txt", delim="|") %>%
  select(-study_id, -domain, -cat_val, -scat_val) -> DTM_F_STR_VS_clean

devtools::use_data(DTM_F_STR_VS_clean, overwrite = TRUE)


spec_SC =
read_delim("data-raw/DB/formatted data/DWH_F_STR_SC.txt", delim="|", n_max = 1000) %>% spec


attributes(spec_SC$cols$seq_id)[["class"]][1] = "collector_character"

DWH_F_STR_SC =
  read_delim("data-raw/DB/formatted data/DWH_F_STR_SC.txt", delim="|", col_types = spec_SC)


DWH_F_STR_SC %>%
  filter(test_cod %in% c("BTH_CTRY","RESD_CTRY")) %>%
  select(sub_id,seq_id, or_res_val, test_cod) %>%
  reshape2::dcast(sub_id+seq_id~test_cod, value.var="or_res_val" ) -> DWH_F_STR_SC_country

devtools::use_data(DWH_F_STR_SC_country, overwrite = TRUE)



