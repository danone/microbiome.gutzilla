library(readr)
library(dplyr)
library(reshape2)


nut_spec =
read_delim("data-raw/DB/formatted data/DWH_F_STR_NUT.txt", delim="|", n_max = 10000) %>% spec

attributes(nut_spec$cols$seq_id)[["class"]][1] <- "collector_character"


f <- function(x, pos) subset(x, or_res_val != "")

DWH_F_STR_NUT =
  read_delim_chunked("data-raw/DB/formatted data/DWH_F_STR_NUT.txt",
                     DataFrameCallback$new(f),
                     chunk_size = 10000,
                     delim="|", col_types = nut_spec)

# example: how to get clean FFQ data

DWH_F_STR_NUT %>%
  filter(met_hod_val == "FFQ", st_res_cod ==  "Daily Intake") %>%
  filter(or_res_val != "Unknown", or_res_val != "Unspecified" , or_res_val != "no_data")  %>%
  select(seq_id,or_res_val,test_val) %>%
  dcast(seq_id~test_val, value.var = "or_res_val")


# example: how to get clean MPED data

DWH_F_STR_NUT %>%
  filter(met_hod_val == "MPED") %>%
  filter(or_res_val != "Unknown",
         or_res_val != "Unspecified" ,
         or_res_val != "no_data",
         or_res_val != "not provided")  %>%
  select(seq_id,or_res_val,test_val) %>%
  mutate(or_res_val = or_res_val %>% as.numeric) %>%
  dcast(seq_id~test_val, value.var = "or_res_val", fill=NA) %>% as_tibble



