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
genus_path = system.file("data-raw/qiime/generated-files-20190512/taxa/genus.qza", package = "agp")
genus = qiime2R::read_qza(genus_path)$data %>% as.data.frame %>% tibble::rownames_to_column("taxa")  %>% as_tibble()


# tidy metadata and add UNSD countries
data("UNSD_countries")

metadata = readr::read_csv2(system.file("data-raw/Metadata_10317_20191022-112414_curatedv4_VSv1.csv", package = "agp"))
#to do: check issue parsing IBD variables

colnames(metadata) = stringr::str_to_lower(colnames(metadata))

metadata <- metadata %>%
  merge(UNSD_countries %>%
          select(`Country or Area`, `Sub-region Name`, `Region Name`) %>%
          mutate(`Country or Area` =  gsub("United Kingdom of Great Britain and Northern Ireland", "United Kingdom", `Country or Area`)) %>%
          mutate(`Country or Area` =  gsub("United States of America", "USA", `Country or Area`)) %>%
          mutate(`Sub-region Name` =  ifelse(`Sub-region Name` %in% c("Central Asia", "Southern Asia"), "Central and Southern Asia",`Sub-region Name`)) %>%
          mutate(`Sub-region Name` =  ifelse(`Sub-region Name` %in% c("Melanesia", "Micronesia","Polynesia"), "Oceania (others)",`Sub-region Name`)),
        by.x="country_of_birth", by.y="Country or Area")

# select abundant genera
load("top_genus_mass.rda")

# remove outliers
outliers = readLines(con="notebook/outliers_samples.txt")
genus %>%
  select(-outliers) %>%
  tibble::column_to_rownames("taxa") %>% .[names(top_genus_mass),]-> genus


## start sampling

for(bootstrap in 1:5){

n=30 # n samples per group

metadata %>%
  filter(!(sample_name %in% outliers)) %>%
  filter(sample_name %in% colnames(genus)) %>%
  select(sample_name,age_cat,sex, `Sub-region Name`,country_of_birth) %>%
  filter(sex %in% c("male","female")) %>%
  filter(!is.na(age_cat) & age_cat != "Not provided") %>%
  group_by(age_cat,sex,`Sub-region Name`) %>%
  sample_n(if(n() < n) n() else n) %>%
  pull(sample_name) -> samples_id_select


metadata %>%
  select(sample_name,`Region Name`,country_of_birth,sex,age_cat,age_years,`Sub-region Name`) %>%
  filter(sample_name %in% samples_id_select) %>%
  with(., xtabs(~`Sub-region Name`+age_cat, data=.))

length(samples_id_select)

metadata %>%
  filter(sample_name %in% samples_id_select) %>%
  select(sample_name,age_cat,sex, `Sub-region Name`,country_of_birth, bmi_cat,gluten,types_of_plants,diet_type  ) %>%
  filter(sex %in% c("male","female")) %>%
  filter(!is.na(age_cat) & age_cat != "Not provided") -> metadata_select


genus_sample_id_select=genus[,colnames(genus) %in% samples_id_select]


#############
fit_genus_list = vector("list",5)

seed   =  444

set.seed(seed); seeds=sample(1:1000, 5)

for(i in 1:5) {

  set.seed(seeds[i])

  fit_genus <- mclapply(1:20, dmn, count=t(genus_sample_id_select), verbose=FALSE, mc.cores=20)

  fit_genus_list[[i]] = fit_genus

  print(i)

}


###################


save(fit_genus_list, file=paste0("fit_genus_list_",bootstrap,".rda"))

}


## group all bootstrap within one file
fit_genus_bootstrap = vector("list",5)
load("fit_genus_list_1.rda")
fit_genus_bootstrap[[1]] = fit_genus_list
load("fit_genus_list_2.rda")
fit_genus_bootstrap[[2]] = fit_genus_list
load("fit_genus_list_3.rda")
fit_genus_bootstrap[[3]] = fit_genus_list
load("fit_genus_list_4.rda")
fit_genus_bootstrap[[4]] = fit_genus_list
load("fit_genus_list_5.rda")
fit_genus_bootstrap[[5]] = fit_genus_list

save(fit_genus_bootstrap, file="fit_genus_bootstrap.rda")





