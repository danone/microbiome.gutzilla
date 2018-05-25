library(readr)
library(reshape2)
library(dplyr)


otu_table_L6 = read.table("data-raw/RAW/raw data/2017-04/Taxa/100nt/otu_table_L6.txt", skip=1, comment.char = "", sep="\t", dec=".",
                          header=TRUE, check.names = FALSE, stringsAsFactors = FALSE)

otu_table_L6 =
  otu_table_L6 %>% as_tibble()



otu_table_L6 %>%
  melt(id.vars=c("#OTU ID")) %>%
  filter(value != 0) %>%
  mutate(`#OTU ID` = gsub("k__|p__|c__|o__|f__|g__","",`#OTU ID`)) %>%
  tidyr::separate(`#OTU ID`,
                  into=c("kig_val","phy_val","cls_val","ord_val","fam_val","gen_val"),
                  sep=";") -> otu_table_L6_clean

otu_table_L6_clean =
  otu_table_L6_clean %>% rename(seq_id = "variable")



compared = merge(otu_table_L6_clean, DWH_F_STR_TXN_clean, by=c("seq_id","kig_val","phy_val","cls_val","ord_val","fam_val","gen_val"))

compared %>% pull(value) %>% summary


### compute JSD distance using parallel

dist.JSD_par =
function (inMatrix,ind_x,ind_y, pseudocount = 10^(round(log10(min(as.matrix(inMatrix)[as.matrix(inMatrix) >
                                                                            0])), 0) - 1), ...)
{
  KLD <- function(x, y) sum(x * log(x/y))
  JSD <- function(x, y) sqrt(0.5 * KLD(x, (x + y)/2) + 0.5 *
                               KLD(y, (x + y)/2))
  matrixColSize <- length(colnames(inMatrix))
  matrixRowSize <- length(rownames(inMatrix))
  colnames <- colnames(inMatrix)
  resultsMatrix <- matrix(0, matrixColSize, matrixColSize)
  for (k in 1:matrixRowSize) {
    for (j in 1:matrixColSize) {
      if (inMatrix[k, j] == 0) {
        inMatrix[k, j] <- pseudocount
      }
    }
  }
  for (i in 1:matrixColSize) {
    for (j in 1:matrixColSize) {
      resultsMatrix[i, j] <- JSD(as.vector(inMatrix[, i]),
                                 as.vector(inMatrix[, j]))
    }
  }
  rownames(resultsMatrix) <- colnames(resultsMatrix) <- colnames
  resultsMatrix <- as.dist(resultsMatrix)
  attr(resultsMatrix, "method") <- "dist"
  return(resultsMatrix)
}







