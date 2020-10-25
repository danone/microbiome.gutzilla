# load libraries

library("biomformat")
library("magrittr")
library("DirichletMultinomial")
library("parallel")
library("reshape2")


# enterotyping: fit a Dirichlet multinomial model

fit_genus_list_motus = vector("list",5)

seed   =  444
output = "enterotypes_motus.txt"

set.seed(seed); seeds=sample(1:1000, 5)

for(i in 1:5) {

  set.seed(seeds[i])

  fit_genus <- mclapply(1:20, dmn, count=t(genus_motus_count_dominant), verbose=FALSE, mc.cores=20)

  fit_genus_list_motus[[i]] = fit_genus



  print(i)

}

# collect Laplace score to find the best fit

lplc = vector("list",5)

for(i in 1:5) {

  lplc[[i]] <- sapply(fit_genus_list_motus[[i]], function(x){attr(x,"goodnessOfFit")[["Laplace"]]})

}

# select the best number of cluster based on majority rule

best_genus_lplc =

  sapply(lplc, which.min) %>% table %>% which.max %>% names %>% as.integer

# assign enterotype id to each samples

enterotypes_motus =

  fit_genus_list_motus[[1]][[best_genus_lplc]] %>%

  mixture(assign=TRUE) %>% as.data.frame %>% set_colnames(c("Enterotypes_id"))

# write the output table

write.table(enterotypes_curated, file=output, row.names=TRUE, sep="\t")

