library(readr)
library(dplyr)
library(reshape2)

# guess spec from txn file

spec_txn =
readr::read_delim(
  file = "data-raw/DB/formatted data/DWH_F_STR_TXN.txt",
  delim = "|" , n_max = 1000) %>% spec

# fix spec for seq_id

attributes(spec_txn$cols$seq_id)[["class"]][1] = "collector_character"

# change spec to skip some columns


attributes(spec_txn$cols$val_all_001)[["class"]][1] = "collector_skip"
attributes(spec_txn$cols$val_txn_001)[["class"]][1] = "collector_skip"
attributes(spec_txn$cols$val_txn_002)[["class"]][1] = "collector_skip"
attributes(spec_txn$cols$val_txn_003)[["class"]][1] = "collector_skip"
attributes(spec_txn$cols$val_txn_004)[["class"]][1] = "collector_skip"
attributes(spec_txn$cols$val_txn_005)[["class"]][1] = "collector_skip"
attributes(spec_txn$cols$val_txn_006)[["class"]][1] = "collector_skip"
attributes(spec_txn$cols$val_txn_007)[["class"]][1] = "collector_skip"
attributes(spec_txn$cols$cmp_001)[["class"]][1] = "collector_skip"
attributes(spec_txn$cols$cmp_002)[["class"]][1] = "collector_skip"
attributes(spec_txn$cols$cmp_008)[["class"]][1] = "collector_skip"
attributes(spec_txn$cols$cmp_009)[["class"]][1] = "collector_skip"

# import txn but skip when st_res_num == 0

f <- function(x, pos) subset(x, or_res_val != 0)

DWH_F_STR_TXN <- read_delim_chunked(
  file="data-raw/DB/formatted data/DWH_F_STR_TXN.txt",
  delim="|",
  DataFrameCallback$new(f),
  chunk_size = 10000, col_types=spec_txn)


# select useful column and filter 100nt only

DWH_F_STR_TXN %>%
  filter(cat_val=="100nt") %>%
  select(seq_id,contains("_val"),or_res_val, st_res_num) %>%
  select(-cat_val,-met_hod_val,-scat_val,-test_val) -> DWH_F_STR_TXN_clean



DWH_F_STR_TXN %>%
  filter(cat_val=="notrim") %>%
  select(seq_id,contains("_val"),or_res_val, st_res_num) %>%
  select(-cat_val,-met_hod_val,-scat_val,-test_val) -> DWH_F_STR_TXN_clean_notrim

DWH_F_STR_TXN_clean %>%
  group_by(seq_id) %>%
  summarize(m=min(or_res_val)) %>%
  mutate(est_n_seq=1/m) %>%
  select(seq_id,est_n_seq) -> nb_reads_estimated

devtools::use_data(nb_reads_estimated, overwrite = TRUE)

devtools::use_data(DWH_F_STR_TXN_clean,overwrite = TRUE)

devtools::use_data(DWH_F_STR_TXN_clean_notrim,overwrite = TRUE)


