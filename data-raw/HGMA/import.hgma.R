


msp_scrap_atlas = function(msp_name) {
  src = paste0("https://www.microbiomeatlas.org/species.php?species_msp=",msp_name)
  tmp = read_html(src)

  #title = tmp %>% html_node(xpath="/html/head/title") %>% html_text()
  tax = tmp %>%
    html_node(xpath="/html/body/div[1]/div/div[1]/table[1]") %>% html_table()


  data.frame(msp_name,tax=tax)


}

atlas_taxo=NULL

for(i in hgma %>% pull(1)  ) {


  tmp = msp_scrap_atlas(i)
  atlas_taxo=rbind(atlas_taxo,tmp)

}


write.csv2(atlas_taxo, file="data-raw/HGMA/atlas_taxo.csv")
usethis::use_data(atlas_taxo, overwrite = TRUE)




hgma = readr::read_csv("data-raw/HGMA/HGMA.web.MSP.abundance.matrix.csv")


atlas_taxo %>% #head(50) %>%
  mutate(X1=factor(X1,levels=c("Phylum:","Class:","Order:","Family:","Genus:","Species:"))) %>%
  select(msp_name,X1,X2) %>%
  reshape2::dcast(msp_name~X1, value.var="X2") -> atlas_taxo_wide

usethis::use_data(atlas_taxo_wide, overwrite = TRUE)


atlas_taxo_wide %>% #head(100) %>%
  merge(hgma , by.x="msp_name", by.y="X1") %>%
  select(-msp_name,-`Species:`) %>%
  group_by(`Phylum:`,`Class:`,`Order:`,`Family:`,`Genus:`) %>%
  summarise_all(sum) -> hgma_genus


usethis::use_data(hgma_genus, overwrite = TRUE)


