library(dplyr)
library(magrittr)
library(readr)
library(SpiecEasi)

file_in="data-raw/feature-table.txt"
file_out_alr="data-raw/taxo_alr.csv"
file_out_alr_ranked="data-raw/taxo_alr_ranked.csv"
file_out_alr_ranked_melted_top10="data-raw/taxo_alr_ranked_melted_top10.csv"

taxo = readr::read_tsv(file_in, skip=1)

Bacteroides_idx = which(taxo$`#OTU ID` == "k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides")

taxo_alr = taxo %>% #.[1:100] %>%
  tibble::column_to_rownames("#OTU ID") %>%
  magrittr::add(1) %>%
  SpiecEasi::alr(divcomp=Bacteroides_idx,removeDivComp=FALSE, mar=1) %>% t() %>%
  as.data.frame() %>%
  tibble::rownames_to_column("#OTU ID")


  taxo_alr %>% #.[,1:10] %>%
  tibble::column_to_rownames("#OTU ID") %>%
  as.matrix() %>%
  apply(2,function(x){(dim(taxo_alr)[1]+1) - rank(x)}) %>%
  apply(2,function(x){round(x)}) -> m

m[which(m>100)] = 100

taxo_alr_ranked =
m %>%
  as.data.frame() %>%
  tibble::rownames_to_column("#OTU ID")


readr::write_csv2(taxo_alr, path=file_out_alr)
readr::write_csv2(taxo_alr_ranked, path=file_out_alr_ranked)


#hist(t(1445-taxo_alr_ranked %>% .[1412,-1]) %>% .[,1], xlim=c(1,100), xlab="genus rank", main="alr ranked", breaks = 300)


top_taxa = c("k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides",
             "k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Ruminococcaceae;g__Faecalibacterium",
             "k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Prevotellaceae;g__Prevotella",
             "k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Lachnospiraceae;g__Roseburia",
             "k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Ruminococcaceae;g__Ruminococcus",
             "k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Lachnospiraceae;g__Blautia",
             "k__Bacteria;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Porphyromonadaceae;g__Parabacteroides",
             "k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Lachnospiraceae;g__Coprococcus",
             "k__Bacteria;p__Verrucomicrobia;c__Verrucomicrobiae;o__Verrucomicrobiales;f__Verrucomicrobiaceae;g__Akkermansia",
             "k__Bacteria;p__Actinobacteria;c__Actinobacteria;o__Bifidobacteriales;f__Bifidobacteriaceae;g__Bifidobacterium")

taxo_alr_ranked %>%
  filter(`#OTU ID` %in% top_taxa) %>%
  mutate(`#OTU ID` = `#OTU ID` %>% strsplit(split=";") %>% sapply(function(x)x[6] %>% gsub("g__","",.))) %>% #.[1:10] %>% head
  reshape2::melt(id.vars="#OTU ID") %>%
  readr::write_csv2(path=file_out_alr_ranked_melted_top10)


#### plot #####


taxo_alr_ranked %>%
  filter(`#OTU ID` %in% top_taxa) %>%
  mutate(`#OTU ID` = `#OTU ID` %>% strsplit(split=";") %>% sapply(function(x)x[6] %>% gsub("g__","",.))) %>% #.[1:10] %>% head
  reshape2::melt(id.vars="#OTU ID") %>%
  ggplot() + geom_histogram(aes(x=value, fill=value<=100)) + facet_wrap(~`#OTU ID`, nr=2) +
  scale_y_log10() + xlab("rank") + ylab("# participants") +
  scale_fill_brewer("genus\ndetected",type="qual") +
  theme_dark()


taxo_alr_ranked %>%
  filter(`#OTU ID` %in% top_taxa) %>%
  mutate(`#OTU ID` = `#OTU ID` %>% strsplit(split=";") %>% sapply(function(x)x[6] %>% gsub("g__","",.))) %>% #.[1:10] %>% head
  reshape2::melt(id.vars="#OTU ID") %>%
  ggplot(aes(x = value, y = `#OTU ID`, fill=value<=100)) +
  geom_density_ridges(stat = "binline", bins = 30, scale = 0.95, draw_baseline = FALSE) +
  xlab("rank") + ylab("# participants") + #scale_y_log10() +
  scale_fill_brewer("genus\ndetected",type="qual") +
  theme_dark()


taxo_alr_ranked %>%
  filter(`#OTU ID` %in% top_taxa) %>%
  mutate(`#OTU ID` = `#OTU ID` %>% strsplit(split=";") %>% sapply(function(x)x[6] %>% gsub("g__","",.))) %>% #.[1:10] %>% head
  reshape2::melt(id.vars="#OTU ID") %>%
  filter(value<100) %>%
  ggplot(aes(x = value, y = `#OTU ID`)) +
  geom_density_ridges(draw_baseline = FALSE) +
  xlab("rank") + ylab("# participants") + #scale_y_log10() +
  scale_fill_brewer("genus\ndetected",type="qual") +
  theme_dark() + scale_x_log10()




cowplot::plot_grid(


taxo_alr_ranked %>%
  filter(`#OTU ID` %in% top_taxa) %>%
  mutate(`#OTU ID` = `#OTU ID` %>% strsplit(split=";") %>% sapply(function(x)x[6] %>% gsub("g__","",.))) %>% #.[1:10] %>% head
  reshape2::melt(id.vars="#OTU ID") %>%
  filter(value<100) %>%
  ggplot(aes(x = value, y = `#OTU ID`, fill = factor(stat(quantile)))) +
  stat_density_ridges(
  geom = "density_ridges_gradient", calc_ecdf = TRUE,
  quantiles = 4, quantile_lines = TRUE
) +
  scale_fill_viridis_d(name = "Quartiles") +
  theme_dark() + scale_x_log10("rank") +
  ylab("microbial genus") +
  theme(
    legend.position = "top"
  ),




taxo_alr_ranked %>%
  filter(`#OTU ID` %in% top_taxa) %>%
  mutate(`#OTU ID` = `#OTU ID` %>% strsplit(split=";") %>% sapply(function(x)x[6] %>% gsub("g__","",.))) %>% #.[1:10] %>% head
  reshape2::melt(id.vars="#OTU ID") %>%
  mutate(value=ifelse(value>=100,"undetected","detected")) %>%
  mutate(value = forcats::fct_relevel(value,"detected", after=Inf)) %>%
  ggplot() + geom_bar(aes(`#OTU ID`,fill=value), position="stack") +
  coord_flip() +
  theme_dark() +
  ylab("# participants") +
  xlab("") +
  theme(axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        legend.position = "top"),

ncol=2,
rel_widths = c(0.6,0.4)


)



