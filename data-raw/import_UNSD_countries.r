#from https://unstats.un.org/unsd/methodology/m49/overview/

UNSD_countries = readxl::read_xlsx("data-raw/UNSD — Methodology.xlsx")


usethis::use_data(UNSD_countries)
