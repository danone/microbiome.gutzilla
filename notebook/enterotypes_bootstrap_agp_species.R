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

# load species table
species_path = system.file("data-raw/qiime/hitdb_summarizetaxacount/seqs.hitdb_L7.txt", package = "gutzilla")
species = readr::read_tsv(species_path, skip = 1) %>% as.data.frame %>% dplyr::rename(taxa=1)  %>% as_tibble()


# tidy metadata and add UNSD countries
data("UNSD_countries")

metadata = readr::read_csv2(system.file("data-raw/Metadata_10317_20191022-112414_curatedv4_VSv1.csv", package = "gutzilla"))
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
load("notebook/top_species_mass.rda")

# remove outliers
outliers = readLines(con="notebook/outliers_samples.txt")
species %>%
  select(-outliers) %>%
  tibble::column_to_rownames("taxa") %>% .[names(top_species_mass),]-> species


## start sampling

for(bootstrap in 1:5){

  n=30 # n samples per group

  metadata %>%
    filter(!(sample_name %in% outliers)) %>%
    filter(sample_name %in% colnames(species)) %>%
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


  species_sample_id_select=species[,colnames(species) %in% samples_id_select]


  #############
  fit_species_list = vector("list",5)

  seed   =  444

  set.seed(seed); seeds=sample(1:1000, 5)

  for(i in 1:5) {

    set.seed(seeds[i])

    fit_species <- mclapply(c(1,2,3,6,10:30,60,100), dmn, count=t(species_sample_id_select), verbose=FALSE, mc.cores=20)

    fit_species_list[[i]] = fit_species

    print(i)

  }


  ###################


  save(fit_species_list, file=paste0("fit_species_list_",bootstrap,".rda"))

}


## group all bootstrap within one file
fit_species_bootstrap = vector("list",5)
load("fit_species_list_1.rda")
fit_species_bootstrap[[1]] = fit_species_list
load("fit_species_list_2.rda")
fit_species_bootstrap[[2]] = fit_species_list
load("fit_species_list_3.rda")
fit_species_bootstrap[[3]] = fit_species_list
load("fit_species_list_4.rda")
fit_species_bootstrap[[4]] = fit_species_list
load("fit_species_list_5.rda")
fit_species_bootstrap[[5]] = fit_species_list

save(fit_species_bootstrap, file="fit_species_bootstrap.rda")





