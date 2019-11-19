library(BiotypeR)

# DWH_F_STR_TXN_clean %>%
#   #filter(seq_id %in% c("10317.000006077","10317.000015703","10317.000015704")) %>%
#   select(-st_res_num) %>%
#   mutate(or_res_val = or_res_val %>% as.numeric) %>%
#   reshape2::dcast(kig_val+phy_val+cls_val+ord_val+fam_val+gen_val~seq_id, fill=0) %>%
#   select(-contains("val")) %>%
#   BiotypeR::dist.JSD() -> AGP_JSD
#
# devtools::use_data(AGP_JSD, overwrite = TRUE)


# DWH_F_STR_TXN_clean %>%
#   filter(seq_id %in% c("10317.000006077","10317.000015703","10317.000015704")) %>%
#   select(-st_res_num) %>%
#   mutate(or_res_val = or_res_val %>% as.numeric) %>%
#   widely(dist.JSD)(seq_id, kig_val+phy_val+cls_val+ord_val+fam_val+gen_val, or_res_val)




