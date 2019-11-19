library("RODBC")
library(dplyr)
library(ggplot2)
library(tidyr)
library(plyr)
.libPaths(c(.libPaths(), '/opt/cloudera/impalaodbc/lib/64'))
conn <- odbcConnect("Sample Cloudera Impala DSN 64")

sqlTables(conn)

## Preparation data
meta <- sqlQuery(conn,"select * from  fr5_rst_dtm.r_str_sub_sam", dec=".")
meta$seq_id[duplicated(meta$seq_id)]
meta <- meta[!duplicated(meta$seq_id),]
dim(meta)
# 17628   551

# tab <- sqlQuery(conn,"select * from  fr5_rst_dtm.f_str_txn where run_id='2017-04' and cat_val='notrim'", dec=".")
tab100nt <- sqlQuery(conn,"select * from  fr5_rst_dtm.f_str_txn where run_id='2017-04' and cat_val='100nt' and (seq_id in (select seq_id from fr5_rst_dwh.r_str_seq where spe_val='Stool'))", dec=".")
tab100nt$seq_id[duplicated(tab100nt$seq_id)]
tab100nt <- tab100nt[!duplicated(tab100nt$seq_id),]
dim(tab100nt)
# 12546  2170

meta <- meta[which(meta$seq_id %in% tab100nt$seq_id),]
dim(meta)
# 12546   551


diet <- c("cnm_hmeal")
ggplot(meta, aes("", fill = factor(cnm_megg))) + 
  geom_bar(aes(y = (count)/sum(..count..)))

+
  facet_wrap(prop.table(table(meta$cnm_hmeal)))


diet <- c("cnm_megg", "cnm_hmeal",
"cnm_rmeal",
"cnm_pmeal",
"cnm_grain",
"cnm_fruit",
"cnm_vegt",
"cnm_fmplt",
"cnm_milkfq",
"cnm_milksbt",
"cnm_fozdes",
"cnm_rdmeat",
"cnm_hfmeat",
"cnm_pltry",
"cnm_seafd",
"cnm_saltsck",
"cnm_sweet",
"cnm_olvoil",
"cnm_whlegg",
"cnm_swtdrk",
"cnm_artswt",
"cnm_water")


dietIndic <- which(colnames(meta) %in% diet)

metaDiet <- gather(meta[,dietIndic], key=Diet, value=Frequency, na.rm=TRUE)

revalue(metaDiet$Diet, 
  c("cnm_megg"="Meat/Eggs", 
  "cnm_hmeal"="Home cooked meal",
  "cnm_rmeal"="Ready to eat meal",
  "cnm_pmeal"="Prepared meal",
  "cnm_grain"="At least 2 servings of whole grains in a day",
  "cnm_fruit"="At Least 2−3 Servings of Fruits in a Day",
  "cnm_vegt"="At Least 2−3 Servings of Vegetables in a Day",
  "cnm_fmplt"="At least one or more servings of fermented vegetables",
  "cnm_milkfq"="At Least 2 Servings of Milk or Cheese a day",
  "cnm_milksbt"="Milk Substitutes",
  "cnm_fozdes"="Frozen Desserts",
  "cnm_rdmeat"="Red Meat",
  "cnm_hfmeat"="High Fat Red Meat",
  "cnm_pltry"="Poultry",
  "cnm_seafd"="Seafood",
  "cnm_saltsck"="Salted Snacks",
  "cnm_sweet"="Sugary Sweets",
  "cnm_olvoil"="Olive Oil",
  "cnm_whlegg"="Whole Eggs",
  "cnm_swtdrk"="Sugar Sweetened Beverages",
  "cnm_artswt"="Artficial sweeteners Beverages",
  "cnm_water"="At Least 1L of Water in a Day"))


ggplot(data=metaDiet, aes(x=Diet, fill = factor(Frequency))) +
  geom_bar(position = "fill") +
  coord_flip()


# test <- meta[1:3, dietIndic]
# class(test$cnm_artswt)
# testDiet <- gather(test, key=Diet, value=Frequency, na.rm=TRUE)

######################
# on a basis without Missing and Unknown values and cnm_artswt
######################

diet <- c("cnm_megg", "cnm_hmeal",
          "cnm_rmeal",
          "cnm_pmeal",
          "cnm_grain",
          "cnm_fruit",
          "cnm_vegt",
          "cnm_fmplt",
          "cnm_milkfq",
          "cnm_milksbt",
          "cnm_fozdes",
          "cnm_rdmeat",
          "cnm_hfmeat",
          "cnm_pltry",
          "cnm_seafd",
          "cnm_saltsck",
          "cnm_sweet",
          "cnm_olvoil",
          "cnm_whlegg",
          "cnm_swtdrk",
          "cnm_water")

dietIndic <- which(colnames(meta) %in% diet)
attributes <- c("Never", "Rarely (less than once/week)","Rarely (a few times/month)", "Occasionally (1-2 times/week)", "Regularly (3-5 times/week)", "Daily")

metaDiet <- gather(meta[,dietIndic], key=Diet, value=Frequency, na.rm=TRUE)

metaDiet$Diet <- revalue(metaDiet$Diet, 
        c("cnm_megg"="Meat/Eggs", 
          "cnm_hmeal"="Home cooked meal",
          "cnm_rmeal"="Ready to eat meal",
          "cnm_pmeal"="Prepared meal",
          "cnm_grain"="At least 2 servings of whole grains in a day",
          "cnm_fruit"="At Least 2−3 Servings of Fruits in a Day",
          "cnm_vegt"="At Least 2−3 Servings of Vegetables in a Day",
          "cnm_fmplt"="At least one or more servings of fermented vegetables",
          "cnm_milkfq"="At Least 2 Servings of Milk or Cheese a day",
          "cnm_milksbt"="Milk Substitutes",
          "cnm_fozdes"="Frozen Desserts",
          "cnm_rdmeat"="Red Meat",
          "cnm_hfmeat"="High Fat Red Meat",
          "cnm_pltry"="Poultry",
          "cnm_seafd"="Seafood",
          "cnm_saltsck"="Salted Snacks",
          "cnm_sweet"="Sugary Sweets",
          "cnm_olvoil"="Olive Oil",
          "cnm_whlegg"="Whole Eggs",
          "cnm_swtdrk"="Sugar Sweetened Beverages",
          "cnm_water"="At Least 1L of Water in a Day"))

metaDiet <- metaDiet[which(metaDiet$Frequency %in% attributes),]
dim(metaDiet)

metaDiet$Frequency <- factor(metaDiet$Frequency, levels=c("Never", "Rarely (less than once/week)", "Occasionally (1-2 times/week)", "Regularly (3-5 times/week)", "Daily"))
metaDiet$Diet <- factor(metaDiet$Diet)

data <- count(metaDiet)
data <- data[order(data$freq),]

reorder <- data[data$Frequency=="Daily",]
reorder <- reorder[order(reorder$freq),]
reorder$Diet <- as.character(reorder$Diet)
data$Diet <- factor(data$Diet, levels=reorder$Diet)

p <- ggplot(data=data, aes(x=Diet, y=freq, fill = Frequency)) +
  geom_bar(stat="identity", position = "fill") +
  scale_fill_brewer( type = "div" , palette = "RdBu" ) +
  coord_flip()
p


