library(dplyr)

file_in="data-raw/taxo.xlsx"

taxo = readxl::read_xlsx(file_in)


taxo_clr = taxo %>%
  #mutate_if(is.numeric, function(x) x+1 ) %>%
  mutate_if(is.numeric, SpiecEasi::clr)


readr::write_csv2(taxo_clr, path="taxo_clr.csv")
