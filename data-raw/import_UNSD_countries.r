#from https://unstats.un.org/unsd/methodology/m49/overview/

UNSD_countries = readxl::read_xlsx("data-raw/UNSD — Methodology.xlsx")


usethis::use_data(UNSD_countries)


UNSD_population = readxl::read_xlsx("data-raw/WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx",
                                    sheet = 1,skip = 16, na = "...")

UNSD_pop_subregion =
UNSD_population %>%
  select(3,Type,`2020`) %>%
  filter(Type %in% c("Subregion","Region", "SDG region")) %>%
  dplyr::rename(Subregion=1, n_pop_2020=3) %>%
  mutate(Subregion=ifelse(Type=="SDG region", Subregion %>% stringr::str_to_title() , Subregion)) %>%
  mutate(Subregion = Subregion %>% gsub("And","and",.) %>% gsub("The","the",.) %>% gsub("\\/"," and ",.)  )




usethis::use_data(UNSD_pop_subregion)
