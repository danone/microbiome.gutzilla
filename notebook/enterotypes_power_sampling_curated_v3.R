#! /usr/bin/Rscript --vanilla
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#

# load libraries
library("dplyr")
library("biomformat")
library("magrittr")
library("DirichletMultinomial")
library("parallel")
library("reshape2")
library("tibble")
devtools::load_all()

# load genus table

load(system.file("data-raw/curatedMetaG/curated_v3_otu_tax.rda", package = "gutzilla"))

OTU %>%
  merge(TAX %>% as.data.frame() %>% select(Genus), by="row.names") %>%
  select(-Row.names) %>%
  group_by(Genus) %>%
  summarise_all(sum) -> curated_v3_genus


# tidy metadata and add UNSD countries
data("country_codes")

metadata = sampleMetadata
#to do: check issue parsing IBD variables

#colnames(metadata) = stringr::str_to_lower(colnames(metadata))

metadata <- metadata %>%
  merge(country_codes %>%
          mutate(`Sub.region.Name` = `Sub.region.Name` %>% as.character()) %>%
          #select(`Country or Area`, `Sub-region Name`, `Region Name`) %>%
          #mutate(`Country or Area` =  gsub("United Kingdom of Great Britain and Northern Ireland", "United Kingdom", `Country or Area`)) %>%
          #mutate(`Country or Area` =  gsub("United States of America", "USA", `Country or Area`)) %>%
          mutate(`Sub.region.Name` =  ifelse(`Sub.region.Name` %in% c("Central Asia", "Southern Asia"), "Central and Southern Asia",`Sub.region.Name`)) %>%
          mutate(`Sub.region.Name` =  ifelse(`Sub.region.Name` %in% c("Melanesia", "Micronesia","Polynesia"), "Oceania (others)",`Sub.region.Name`)),
        by.x="country", by.y="ISO3166.1.Alpha.3")

metadata <- metadata %>%
  mutate(age_category2 =
           case_when(
             age <= 3 ~ "infant",
             age <= 10 & age > 3 ~ "child",
             age <=20 & age > 10 ~ "10s",
             age <=30 & age > 20 ~ "20s",
             age <=40 & age > 30 ~ "30s",
             age <=50 & age > 40 ~ "40s",
             age <=60 & age > 50 ~ "50s",
             age <=70 & age > 60 ~ "60s",
             age > 70 ~ "70+",

           ))


# select abundant genera


curated_v3_genus %>%
  ungroup() %>%
  mutate_if(is.numeric, function(x) x/sum(x)) -> curated_v3_genus_prop



curated_v3_genus_prop %>%
  tibble::column_to_rownames("Genus") %>%
  as.matrix %>%
  apply(1,sum) %>%
  sort %>% rev %>% head(30) -> top_genus_mass_curated

# remove outliers
curated_v3_genus_prop %>%
  filter(Genus %in% names(top_genus_mass_curated)) %>%
  summarise_if(is.numeric, sum) -> dominant_mass_per_sample

dominant_mass_per_sample %>%
  t %>%
  as.data.frame() %>%
  arrange(V1) %>%
  filter(V1>0.25) %>% row.names() -> sample_curated_to_select

curated_v3_genus_prop %>%
  mutate_if(is.numeric, function(x) round(x*10^4,0)  ) %>%
  filter(Genus %in% names(top_genus_mass_curated)) %>%
  tibble::column_to_rownames("Genus") %>%
  select(all_of(sample_curated_to_select)) -> genus


## start sampling


for(power_sampling in c(30,100,300,1000,3000)) {

for(bootstrap in 1:3){

n=30 # n samples per group

metadata %>%
  #filter(!(sample_name %in% outliers)) %>%
  filter(sample_id %in% colnames(genus)) %>%
  select(sample_id,age_category2,gender, `Sub.region.Name`) %>%
  filter(gender %in% c("male","female")) %>%
  filter(!is.na(age_category2) & age_category2 != "Not provided") %>%
  #filter(!(age_category2 %in% c("infant","child","10s"))) %>% #remove infant, child and teens
  group_by(age_category2,gender,`Sub.region.Name`) %>%
  sample_n(if(n() < n) n() else n) %>%
  pull(sample_id) -> samples_id_select

#samples_id_select %>% length()
#metadata %>% filter(sample_id %in% samples_id_select) %>% with(., xtabs(~`Sub.region.Name`+age_category2, data=.))


#
# metadata %>%
#   select(sample_name,`Region Name`,country_of_birth,sex,age_cat,age_years,`Sub-region Name`) %>%
#   filter(sample_name %in% samples_id_select) %>%
#   with(., xtabs(~`Sub-region Name`+age_cat, data=.))
#
# length(samples_id_select)
#
# metadata %>%
#   filter(sample_name %in% samples_id_select) %>%
#   select(sample_name,age_cat,sex, `Sub-region Name`,country_of_birth, bmi_cat,gluten,types_of_plants,diet_type  ) %>%
#   filter(sex %in% c("male","female")) %>%
#   filter(!is.na(age_cat) & age_cat != "Not provided") -> metadata_select
#

genus_sample_id_select=genus[,colnames(genus) %in% samples_id_select]

# sub sampling

genus_sample_id_select=sample(genus_sample_id_select, power_sampling, replace=FALSE)


#############

nb_seed=3

fit_genus_list = vector("list",nb_seed)

seed   =  444

set.seed(seed); seeds=sample(1:1000, nb_seed)

for(i in 1:nb_seed) {

  set.seed(seeds[i])

  fit_genus <- mclapply(c(1:30), dmn, count=t(genus_sample_id_select), verbose=FALSE, mc.cores=20)

  fit_genus_list[[i]] = fit_genus

  print(i)

}


###################


save(fit_genus_list, file=paste0("fit_genus_list_",power_sampling,"_",bootstrap,"_curated_v3.rda"))

}

}


## group all sub sampling within one file
fit_genus_power_sampling_curated = vector("list",15)
load("fit_genus_list_30_1_curated_v3.rda")
fit_genus_power_sampling_curated[[1]] = fit_genus_list
load("fit_genus_list_100_1_curated_v3.rda")
fit_genus_power_sampling_curated[[2]] = fit_genus_list
load("fit_genus_list_300_1_curated_v3.rda")
fit_genus_power_sampling_curated[[3]] = fit_genus_list
load("fit_genus_list_1000_1_curated_v3.rda")
fit_genus_power_sampling_curated[[4]] = fit_genus_list
load("fit_genus_list_3000_1_curated_v3.rda")
fit_genus_power_sampling_curated[[5]] = fit_genus_list


fit_genus_power_sampling_curated = vector("list",15)
load("fit_genus_list_30_2_curated_v3.rda")
fit_genus_power_sampling_curated[[6]] = fit_genus_list
load("fit_genus_list_100_2_curated_v3.rda")
fit_genus_power_sampling_curated[[7]] = fit_genus_list
load("fit_genus_list_300_2_curated_v3.rda")
fit_genus_power_sampling_curated[[8]] = fit_genus_list
load("fit_genus_list_1000_2_curated_v3.rda")
fit_genus_power_sampling_curated[[9]] = fit_genus_list
load("fit_genus_list_3000_2_curated_v3.rda")
fit_genus_power_sampling_curated[[10]] = fit_genus_list


fit_genus_power_sampling_curated = vector("list",15)
load("fit_genus_list_30_3_curated_v3.rda")
fit_genus_power_sampling_curated[[11]] = fit_genus_list
load("fit_genus_list_100_3_curated_v3.rda")
fit_genus_power_sampling_curated[[12]] = fit_genus_list
load("fit_genus_list_300_3_curated_v3.rda")
fit_genus_power_sampling_curated[[13]] = fit_genus_list
load("fit_genus_list_1000_3_curated_v3.rda")
fit_genus_power_sampling_curated[[14]] = fit_genus_list
load("fit_genus_list_3000_3_curated_v3.rda")
fit_genus_power_sampling_curated[[15]] = fit_genus_list


save(fit_genus_power_sampling_curated, file="fit_genus_power_sampling_curated_v3.rda")





