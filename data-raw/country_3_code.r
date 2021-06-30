url="https://datahub.io/core/country-codes/r/country-codes.csv"

country_codes= read.csv(url)

country_codes %>%
  select(ISO4217.currency_country_name, ISO3166.1.Alpha.3,Region.Name,Sub.region.Name) -> country_codes

usethis::use_data(country_codes, overwrite = TRUE)
