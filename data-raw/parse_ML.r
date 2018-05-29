library(readr)
library(dplyr)


spec_ML =
read_delim("data-raw/DB/formatted data/DWH_F_STR_ML.txt", delim="|", n_max = 100000) %>% spec

attributes(spec_ML$cols$seq_id)[["class"]][1] = "collector_character"

DWH_F_STR_ML =
read_delim("data-raw/DB/formatted data/DWH_F_STR_ML.txt", delim="|", col_types = spec_ML)


# DWH_F_STR_ML %>%
#   #filter(grepl("FERMENTED",test_cod)) %>%
#   select(test_cod,seq_id,sub_id,test_val, or_res_val) %>%
#   mutate(or_res_val_len = stringr::str_length(or_res_val)) %>%
#   group_by(test_cod,or_res_val) %>%
#   summarize(n=n()) %>%
#   arrange(desc(n)) %>%
#   filter(n>10) %>%
#
#   group_by(test_cod)
#   as.data.frame()
#
#
# DWH_F_STR_ML %>%
#   filter(grepl("YOGURT",test_cod))
#
# DWH_F_STR_ML %>% filter(cat_val == "General Diet Information", sub_id == "d102d428d") %>%
#   filter(test_cod == "WATER_SOURCE")

DWH_F_STR_ML %>%
  filter(cat_val == "General Diet Information") %>%
  select(sub_id,seq_id,test_cod,or_res_val) %>%
  group_by(sub_id,seq_id,test_cod, or_res_val) %>%
  slice(1) %>%
  reshape2::dcast(sub_id+seq_id~test_cod) %>%
  as_tibble -> DWH_F_STR_ML_general_diet

  devtools::use_data(DWH_F_STR_ML_general_diet)

  DWH_F_STR_ML %>%
    filter(cat_val == "Fermented Foods") %>%
    select(sub_id,seq_id,test_cod,or_res_val) %>%
    group_by(sub_id,seq_id,test_cod, or_res_val) %>%
    slice(1) %>%
    filter(test_cod != "FERMENTED_OTHER") %>%
    filter(or_res_val %in% c("Yes","No") ) %>%
    #reshape2::dcast(sub_id+seq_id~test_cod) %>%
    as_tibble -> DWH_F_STR_ML_fermented

    devtools::use_data(DWH_F_STR_ML_fermented, overwrite = TRUE)

    #ggplot(DWH_F_STR_ML_fermented) + geom_bar(aes(x=test_cod,fill=or_res_val)) + coord_flip()




  DWH_F_STR_ML %>%
    filter(cat_val %in% c(
      "Fruits and Vegetables",
      "Dairy",
      "Grains/Fiber",
      "Meat/Seafood",
      "Detailed Dietary Information")) %>%
    filter(test_cod != "WK_NBPLT") %>%
    select(sub_id,seq_id,test_val,or_res_val) %>%
    filter(!(or_res_val %in% c("Miissing","Unknown","Not sure","Yes","No","I eat both solid food and formula/breast milk") )) %>%
    group_by(sub_id,seq_id,test_val, or_res_val) %>%
    slice(1) %>%
    filter(test_val != "Consumption - Artificial Sweeteners") %>%
    #reshape2::dcast(sub_id+seq_id~test_val) %>%
    as_tibble -> DWH_F_STR_ML_detail_diet

  devtools::use_data(DWH_F_STR_ML_detail_diet)

    #ggplot() + geom_bar(aes(x=test_val,fill=or_res_val)) + coord_flip()


#
  # DWH_F_STR_ML %>%
  #   filter(cat_val %in% c("Specialized Diet")) %>%
  #   select(sub_id,seq_id,test_val,or_res_val) %>%
  #   group_by(sub_id,seq_id,test_val, or_res_val) %>%
  #   slice(1) %>%
  #   #reshape2::dcast(sub_id+seq_id~test_val) %>%
  #   as_tibble %>%
  #   filter(or_res_val %in% c("Yes","No")) %>%
  #   ggplot() + geom_bar(aes(x=test_val,fill=or_res_val)) + coord_flip()
#
#
  # merge(DWH_F_STR_ML_detail_diet, DWH_F_STR_ML_general_diet, by="seq_id") %>%
  #   as_tibble %>%
  #   ggplot() + geom_bar(aes(x=test_val,fill=or_res_val)) + coord_flip() + facet_wrap(~DIET_TYPE, scale="free_x")
  #
