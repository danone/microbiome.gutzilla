url="https://www.mediterranee-infection.com/wp-content/uploads/2020/05/OXYTOL-1.3.xlsx"

download.file(url, destfile = "OXYTOL-1.3.xlsx")


oxytol = readxl::read_xlsx("OXYTOL-1.3.xlsx", sheet = 1)

oxytol %>%
  filter(`Obligate anerobic bacteria` %in% c(0,1,2)) %>%
  mutate(`Obligate anerobic bacteria` = ifelse(`Obligate anerobic bacteria` == 2, 1, 0)) %>%
  select(1:2) -> oxytol



usethis::use_data(oxytol, overwrite = TRUE)
